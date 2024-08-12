+++ 
draft = true
date = 2024-08-12T19:06:21-04:00
title = "Trying out Atomic Desktops"
description = "In which I try out a \"new\" kind of Linux Desktop and attempt to validate my distro-hopping by writing a blog post about it."
slug = ""
authors = []
tags = []
categories = []
externalLink = ""
series = []
+++

For my personal workstations, Arch Linux has been my daily driver for just over
a decade now.[^1] Once a year or so, I take a step back to re-evaluate and do a
little distro-hopping, but invariably I'm back to signing off every message
with "btw" within a month and enjoying that clean install smell. *But what if
*every* boot was like a clean install?*

On these yearly adventures Fedora tends to be a common stop, as it provides a
quick and painless way to check out the latest (mostly) vanilla GNOME and KDE
Plasma experiences before I go running back to my beloved Sway. However,
instead of grabbing the standard Workstation images this go around, I had
immutable desktops on the mind.

[^1]: And what a fun realization that was. Boy do I feel old.

# Atomic Desktops, what are those?

Compared to more traditional Linux setups, Fedora's Atomic Desktops (probably
better known by the name of the GNOME-specific flavor, Silverblue) rely on
[OSTree](https://ostreedev.github.io/ostree/) behind the scenes. This means
they differ in two major ways.

First, the system[^2] is *immutable*. This means that a given
version of the OS will boot in the same state throughout the lifetime of the
install. Persistent state for things like home directories gets tucked away in
`/var` and layered on top of the immutable parts via bind mount magic. Due to
the nature of this setup, the primary means for running software not included
with the system are through sandboxed environments like Flatpak or Podman
containers.

Second, updates are *atomic* (hence the name). Instead of updating individual
packages as on a traditional system, a new complete system image is put in
place and staged for the next boot, without affecting the running system.
If the update fails, the system remains functional. This also allows for easy
rollbacks should a successful update prove to be problematic at runtime.

Taken together, these features promise a near bulletproof OS install. Similar
architectures have also been battle-tested by the likes of Android, iOS, and
more recently macOS.

[^2]: "System" here meaning the kernel and the core set of applications and
    support files included with the OS, not the entire root filesystem.

# But what's the experience like in practice?

Fedora ships a variety of Atomic Desktop images featuring different desktop
environments, largely mirroring the more traditional Workstation images. I'd
gone to Fedora mainly to try out Plasma 6, so I chose to install that flavor,
Kinoite, on my test machine. Once installed, there wasn't really much of
anything different from using a normal system, aside from a slightly different
GRUB menu offering the ability to override the currently active system image
and boot into another one.

System updates, instead of using `dnf`, use `rpm-ostree update`. Ordinarily I'm
hesitant to enable system-level automatic updates, but I've felt confident in
enabling them with Kinoite. The update process can't bork my running system,
and if something *does* go wrong on reboot I'm a quick rollback away from a
working system.[^3]

There are essentially three officially sanctioned ways to install additional
packages, each serving their own purpose. Coming from a world where `pacman`
manages everything on my system, I'm not a fan of this as an idea, but in
practice it's been an easy adjustment. General GUI applications get installed
as Flatpaks[^4], CLI applications and development tools (more on that later) go
into containers using [Toolbx](https://containertoolbx.org/), while things that
just *need* a traditional install (think hardware enablement, VPN clients,
etc.) can use `rpm-ostree install` to layer normal repo packages on top of the
base image.

[^3]: I've tested this for giggles, but thankfully haven't *needed* it yet.
[^4]: Again, I'd have scoffed at this even a few years ago, but Flatpak has
    come a long way.

# What about development?

Development on an ostree-based desktop makes for an interesting conversation.
Container-driven development is hardly a new concept, but while I'd elsewhere
consider it more of a curiosity, here it's the default. The value proposition
is basically the same as that of virtual environments used by the likes of
Python: projects that need it can easily be built in an isolated environment to
avoid conflicts with others, or the base system.

VS Code has first class support for containers these days using the [Dev
Containers](https://code.visualstudio.com/docs/devcontainers/containers)
plugin. There are some similar efforts for my weapon of choice, Neovim, but
that has the advantage of being light enough to reasonably just install inside
of each development container. I use the excellent
[Neovide](https://neovide.dev/) as a frontend, which can easily be persuaded to
run Neovim within a container using `neovide --nvim-bin 'toolbox run
--container <NAME> nvim`.

In the last couple of months using Fedora Atomic, I've happily been developing
with C++, Rust, Python, and C# without any slowdown to my work. In fact, even
if I don't stick with the immutable desktop long term, I may keep the
container-first workflow.

# Any sticking points?

While I've had a mostly positive experience with Fedora Atomic, I do have a
couple of minor gripes. Atomic updates are very cool in concept, but when
package layering comes into play, things can get messy.

Say I've got a mission-critical package `foo` layered on my system, because it
isn't included in the base image. It depends on a somewhat commonly used
`barlib` package, which *is* included in the base image. Now suppose I try to
run an update. A new patch for `barlib` was recently released, and has landed
in the Fedora repos, but has not yet made it into an ostree image. There's now
a conflict between the versions of `barlib` required by the base image and
packages I've layered on top of it. If we pick a particular version to win out
(and how would we?), there's a decent chance that something will break after
the update.

In practice if a situation like this occurs, `rpm-ostree` chokes and refuses to
do anything. The only reliable solution at this point is to simply wait until a
new base image is available that brings the versions back in sync. Most of the
time this is fine, but on one occasion it has prevented me from layering a new
package that I wanted.

# What's next?

Immutable desktops have been around for a while now, but there are some very
interesting developments happening these days. `rpm-ostree` now has the ability
to deploy and boot using OCI images, along with a full complement of Fedora
Atomic container images to build from. The [Universal
Blue](https://universal-blue.org/) team has been demonstrating the potential
for this by deploying a fleet of images tailored to particular use cases using
GitHub Actions.

Currently, I provision my workstations using Ansible, but I very much see a
future where I instead have a Containerfile that builds a single golden image I
can pull down to my machines.

Overall I've been very pleased with Fedora Atomic, and I think I'll stick with
it for a while.[^5] Besides, I'm using Arch for my development containers, so I
can technically still proclaim:

*i use arch, btw*

[^5]: Though I will probably wind up migrating to the Sway flavor.

