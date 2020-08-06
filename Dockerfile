FROM alpine:3.12

RUN apk add git
ADD https://github.com/gohugoio/hugo/releases/download/v0.74.3/hugo_0.74.3_Linux-64bit.tar.gz /
RUN tar xf hugo_0.74.3_Linux-64bit.tar.gz
RUN /hugo version
WORKDIR /build
COPY . .
RUN /hugo --minify
RUN ls /build/public

FROM caddy:2-alpine
WORKDIR /var/www/html
COPY --from=0 /build/public .
COPY Caddyfile /etc/caddy/Caddyfile
