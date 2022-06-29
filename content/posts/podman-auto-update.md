+++ 
date = 2022-06-29T15:29:29-04:00
title = "Auto-updating Containers, the Podman Way"
description = ""
slug = ""
authors = []
tags = ["podman", "systemd"]
categories = []
externalLink = ""
series = []
+++

In recent years Podman has become a very capable (and to some, preferable)
alternative to Docker for people deploying containers who don't quite fit the
Kubernetes usecase. However, the traditional Docker convention of deploying a
[Watchtower](https://containrrr.dev/watchtower/) container alongside the
application doesn't work for Podman without enabling the Docker compatibility
layer. Instead, Podman provides similar functionality via `podman auto-update`.

> **Note:** This method relies on Podman's systemd service generation, users of
> other init systems unfortunately need a different method to implement
> auto-updates.

Here's an example `podman create`[^1] command to create a container from this
website's image:

```
$ podman create --label io.containers.autoupdate=registry \
             --name website \
             ghcr.io/emar10/emar10.dev:latest
```

Note the `io.containers.autoupdate` label. The idea of opting containers into
auto updates in this way should be familiar to Watchtower users. The value of
`registry` specifies that Podman should check the remote registry for updates.

In order for `podman auto-update` to do its job, a systemd service for the
container is needed. `podman generate` can create this automagically:

```
$ podman generate systemd --new website > ~/.config/systemd/user/container-website.service
$ systemctl --user daemon-reload
$ systemctl --user start container-website.service
```

The `--new` option creates a systemd unit that can fully recreate the container
instead of simply stopping or starting an existing container. Starting the
generated unit populates the `PODMAN_SYSTEMD_UNIT` environment variable that
Podman needs to successfully recreate the container on update.

Running `podman auto-update` now shows the container, its associated systemd
unit, the update policy, and the update status:

```
$ podman auto-update
UNIT                       CONTAINER               IMAGE                             POLICY      UPDATED
container-website.service  5bb378736e92 (website)  ghcr.io/emar10/emar10.dev:latest  registry    false
```

To cap off the automation magic, Podman provides a oneshot systemd service to
run auto-update, and a timer to trigger it:

```
$ systemctl --user enable --now podman-auto-update.timer
```

By default, this timer will trigger an update once daily at midnight. This can
be changed by creating an override file (either by hand or using `systemctl
--user edit podman-auto-update.timer`. For example, to update once per hour
with a five minute randomized delay:

```
$ cat ~/.config/systemd/user/podman-auto-update.timer.d/override.conf
[Timer]
OnCalendar=hourly
RandomizedDelaySec=15
```

# Additional Reading

* [podman-auto-update](https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html)
  from the official Podman documentation
* [podman-generate-systemd](https://docs.podman.io/en/latest/markdown/podman-generate-systemd.1.html)
  from the official Podman documentation

[^1]: `podman create` is used instead of `podman run` to avoid issues with
starting the systemd service later on.

