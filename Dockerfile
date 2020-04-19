FROM alpine:3.11

ADD https://github.com/gohugoio/hugo/releases/download/v0.69.0/hugo_0.69.0_Linux-64bit.tar.gz /
RUN tar xf /hugo_0.69.0_Linux-64bit.tar.gz
RUN /hugo version
WORKDIR /build
COPY . .
RUN /hugo --minify

FROM caddy:2.0.0-rc.3-alpine
WORKDIR /usr/share/caddy
COPY --from=0 /build/public .
