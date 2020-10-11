---
title: "Automated Website Deployment With Docker"
date: 2020-10-02T16:43:18-04:00
draft: false
tags:
- Hugo
- Docker
- Caddy
- blogging
---

Fully automated deployment is often the holy grail for users of static site
generators like Hugo or Jekyll, providing the convenience of easily pushing
new content without sacrificing the lightweight results. Today I'm going to
share my process for doing this with my website using Docker and the
ecosystem that's grown up around it.

# Creating a Docker Image

First, I started by Dockerizing my website. With a fully static tree, the
Dockerfile is cake mix. Most popular web servers have official images on
Docker Hub, lately I've been using [Caddy](https://caddyserver.com). For the
first version of my Dockerfile, I started with Caddy's image, then simply
inject both my configuration file and the `public` directory.

```Dockerfile
FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY public /var/www/html
```

This was nice, but I use [Hugo](https://gohugo.io), which means that the site
needs to be built before the `public` directory gets pulled into the image.
To integrate this into the image building process, I added on an intermediate
image to my Dockerfile to run Hugo. There are plenty of community images that
contain Hugo, but I found it easier to simply start with an Alpine Edge
container and install Hugo from there. After running `hugo build` in the
first stage, the results are copied into the final image. Here's the final
Dockerfile:

```Dockerfile
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
```

# Automatically Pulling New Images in Production

Armed with a fully self-contained image of my website, I `docker-compose`'d to
glory on my production server with web ports forwarded to the container and
some of Caddy's directories mounted as volumes to avoid losing SSL
certificates.

At this point I would still need to manually log in to my server to pull new
images. Enter [Watchtower](https://containrrr.dev/watchtower/). On a system
where *all* containers should be updated automatically, Watchtower doesn't
require any fancy configuration. I also run some third-party containers that
I would rather pull manually however, so this wouldn't quite work.

Thankfully, Watchtower can be configured for this pretty easily. Out of the
box it only ignores specific containers if instructed, an added environment
variable does the oppposite, which worked better for my case. From there I
added my website container as an exception. Here's a snippet of my
`docker-compose.yml`:

```yaml
watchtower:
  image: containrr/watchtower
  environment:
    - WATCHTOWER_LABEL_ENABLE

website:
  labels:
    com.centurylinklabs.watchtower.enable: "true"
```

# Tying Everything Together

The last piece of the puzzle remaining was to get my image to build and
upload to a registry automatically on push. Most any CI solution would have
done the trick here, but I settled on using Docker Hub itself to settle both
items. The completed chain is this:

* I make changes to the Git repository and push to `master` on GitHub

* Docker Hub picks up on this and queues an image build

* Watchtower finds the new image and pulls it onto my production server

With this setup, all I need to to be able to update my website is a text
editor and Git. There's certainly room for refinement, but that will be a
topic for a later post...
