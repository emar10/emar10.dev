FROM docker.io/rust:1 as sous

RUN cargo install --version ~0.3 sous
COPY ./cookbook /cookbook
COPY ./recipe.md /recipe.md
RUN sous -m template -t recipe.md -o output/ cookbook/

FROM docker.io/alpine:edge as hugo

RUN apk add hugo
RUN hugo version

COPY . /src
COPY --from=sous /output/* /src/content/cookbook/
WORKDIR /src
RUN hugo --minify
RUN ls /src/public

FROM docker.io/library/caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=hugo /src/public /var/www/html
