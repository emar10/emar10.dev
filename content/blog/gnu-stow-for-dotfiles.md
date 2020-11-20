---
title: "Managing dotfiles with GNU Stow"
date: 2020-11-20T18:20:01-05:00
tags:
  - terminal
  - stow
  - CLI
  - tools
  - environment
---

Managing the myriad configuration and environment files (or *dots* as the
cool kids call them) among multiple machines can be a huge pain. There are
plenty of approaches to bootstrapping new systems with precious Git configs
and `.vimrc`s, but my favored solution is with a tiny GNU tool called
[`stow`](https://www.gnu.org/software/stow/).

Stow bills itself as a "symlink farm manager." It allows you to keep a tidy
directory of "packages" whose contents can be quickly symlinked into and out
of the stow's parent directory. One of the more common use cases is as a
package manager of sorts for software installed from source. One might `make`
and `make install` with `PREFIX=/usr/local/bin/<packagename>`, then `stow
<packagename>` to cleanly and reversibly install it without needing to rely
on a decent `make uninstall` target.

As it happens, this concept also happens to work quite well for managing
dotfiles! Here's how I do it:

First, set up a place in your home directory to store everything, something
like `dotfiles`. Inside, create more directories for each package you want to
track configuration of. Then yank the files for each package into their new
directory, recreating the same path relative to your home directory. For
example, `~/.config/alacritty/alacritty.yml` would be moved to
`~/dotfiles/.config/alacritty/alacritty.yml`.

Now, from inside `dotfiles`, do `stow --no-folding <packages>`. The
`--no-folding` option is used to make sure that no directories are symlinked
and avoid any unwanted files winding up in the `dotfiles` repository.

From here, you can track the contents of `dotfiles` with Git, sync it with
your cloud storage service of choice, etc. Now, bootstrapping a new system is
as simple as grabbing the repository and `stow`ing the packages you need!
