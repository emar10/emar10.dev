+++ 
date = 2024-11-30
title = "Running Neovide with Containers"
description = "In which I trick a Neovim frontend into having good enough container support."
slug = ""
authors = []
tags = ["linux", "neovim", "containers"]
categories = []
externalLink = ""
series = []
+++

As mentioned in a previous post, while experimenting with Fedora Atomic Desktops I largely switched
to using containers for my development environments. This came with some mild friction with my
editor setup, as the Neovim ecosystem doesn't really support container-aware development. Until
recently, my solution was to first install Neovim in each development container, then convince
Neovide (my frontend of choice) to use the container binary instead of the system binary using its
`--neovim-bin` flag. While I'm still installing Neovim in all of my dev containers,[^1] I've added
some convenience scripts for launching Neovide that I thought were worth sharing.

[^1]: Given the size of a Neovim install, I don't see a reason to try and eliminate this.

# Launcher Script

My goal was to add an (optional) launcher menu for Neovide that would allow me to pick from a list
of Distrobox containers on my system, then adjust the `nvim` invokation based on the selection. At
the core of this is a quick and dirty Bash script leveraging `kdialog`[^2].

[^2]: This is mostly because I'm using KDE at the moment; the script could easily be modified to
    instead use `zenity`, `dmenu`, or any other GUI menu tool.

First, I grab a list of container names managed by Distrobox. Due to a quirk with `kdialog`'s CLI,
I also transform this into a list of options with each container name listed twice:

```bash
containers=$(distrobox list --no-color) | awk 'NR>1 {print $3}')

options=()
while IFS= read -r container; do
  options+=("$container" "$container") 
done <<< "$containers"
```

Next, I use `kdialog` to present a menu and get a choice from the user:

```bash
choice=$(kdialog --menu "Select a container to open Neovim" "${options[@]}")
```

Finally, I start Neovide, replacing the default Neovim path with a Distrobox command to launch
`nvim` inside of the target container. I also transparently pass any other arguments (most often a
filename to open):

```bash
exec neovide --neovim-bin "distrobox enter $choice -- nvim" $@
```

![The container selection menu in action](/images/neovide-in-containers/menu.png)

# Desktop Integration

To tie everything together, I added an action to the XDG desktop entry provided with Neovide that
invokes the script. This required adding a list of `Actions` to the `[Desktop Entry]` tag, then a
definition for my custom action at the end of the file.

```desktop
[Desktop Entry]
Type=Application
Exec=neovide %F
Icon=neovide
Name=Neovide
Keywords=Text;Editor;
Categories=Utility;TextEditor;
Comment=No Nonsense Neovim Client in Rust
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Actions=OpenInContainer;

[Desktop Action OpenInContainer]
Name=Open in Container
Exec=${HOME}/.local/bin/neovide-distrobox %F
```

To avoid the package manager clobbering my changes, I save the resulting `.desktop` file to
`~/.local/share/applications/`, and run `update-desktop-database ~/.local/share/applications` to
immediately force an update in my desktop environment. Right-clicking the entry now includes a
"Open in Container" option that uses the launcher script.

Now, Neovide is (sort of) container-aware!

# Further Reading

- [emar10/dotfiles](https://github.com/emar10/dotfiles/tree/3857ec46dc4b820f88522015bac0563dc248ff39/neovide/.local):
  The complete launcher script and modified Desktop Entry.
- [Desktop Entry Specification](https://specifications.freedesktop.org/desktop-entry-spec/latest/):
  Other useful information for hacking Desktop Entries.

