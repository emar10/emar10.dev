FROM alpine:edge

RUN apk add hugo
RUN hugo version

COPY . /src
WORKDIR /src
RUN hugo --minify
RUN ls /src/public

FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY --from=0 /src/public /var/www/html
