+++ 
draft = true
date = 2025-08-05T15:12:14-04:00
title = "Cursed Commands - No SCP? No problem!"
description = "In which I go to greath lengths to find a lazier way to move a file."
slug = ""
authors = []
tags = []
categories = []
externalLink = ""
series = []
+++

Environmental constraints can drive us to do some silly things as humans. In the
many years I've been a Linux user, I've occasionally found myself stringing
together some commands that at best stretch the intent of the program authors,
and at worst feel downright filthy. I've decided to write some blog posts about
some of these; partially to demonstrate the flexibility of good old fashioned
command line tools, partially in the hopes that some poor fools in a similar
situation might find them useful, but mostly for fun if I'm being honest.

For this first example, I wanted to transfer a compressed firmware image from
one machine to another, connected via Ethernet. Just use `scp`, right? Well,
not quite.

## The Situation

My goal was to install [OpenWrt](https://openwrt.org/) on an old
[APU2](https://www.pcengines.ch/apu2.htm) board from the late, great PCEngines.
The APU was actively running a live image off of a USB stick, and connected via
Ethernet to a workstation for accessing the web UI. But to properly install to
the internal storage I needed to transfer a firmware image from the workstation
and `dd` it.

With an active network connection between the two machines, the solution is
obvious:

```bash
scp firmware.img.gz root@apu2:
```

Unfortunately, OpenWrt ships with the lightweight `dropbear` SSH server, and does
not play nice with `scp` out of the box. So what next?

## The "Solution"

At this point any number of things could have worked, including but not limited
to:

- Connect the APU to the internet, use `curl` to download the image directly.
- Prepare and mount a USB stick with the image on it.
- Reboot into a live image that has `scp` support (just about anything else).
- *Search the OpenWrt documentation for clues.*

But, all of those options (with the exception of the latter) would have required
physically interacting with the APU in some way like a caveman. Instead, I did
this from the workstation:

```bash
tar -czf - firmware.img.gz | ssh root@apu2 'tar -xz'
```

First, `tar` is called with `-f -` in order to write the archive to `stdout`.
This then gets piped into `ssh`, which has been told to have `tar` read from
`stdin` on the APU.

Did it work? Yes. Did it feel good? Absolutely not. Despite
sending a gzipped file, I applied *another* layer of compression out of habit.[^1]
Piping anything to `ssh` feels weird. And worst of all? I actually could have
just used `scp`. Lo and behold, per [OpenWrt's documentation][1], `scp -O`.

[1]: https://openwrt.org/docs/guide-user/base-system/dropbear#openssh_compatibility

[^1]: For those wondering, yes, I *could* have sent the data to `gunzip` instead, or
    even further piped that output directly to `dd`.

---

This exercise was generally just silly. But, in it there is one important
takeaway:

If you have two systems that have a
network connection, whatever the constraints at play (self-imposed or
otherwise), *you have the means to transfer files between them*.
