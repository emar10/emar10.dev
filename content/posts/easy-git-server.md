+++ 
date = 2024-01-20
title = "You (probably) don't need a self-hosted code forge"
description = "Exploiting SSH, Git, and whatever hardware you've got laying around for a dead simple, dead easy secondary remote."
tags = ["git", "ssh", "linux"]
+++

If you use any kind of version control software, there's a decent chance that
it's Git. And if you use Git, there's a *very strong* chance that you host your
repositories with a publicly accessible code forge, be that GitHub, GitLab, or
even [the original](https://sourceforge.net/). But what happens when you want a
different remote? Perhaps you use something like
[hledger](https://hledger.org/) to track your finances and don't want to send
semi-sensitive data to a cloud service, private or otherwise. Or maybe you're
aiming to implement backups and don't want to rely on mirroring to a different
public service. You could go with self-hosted versions of forges like GitLab or
SourceHut, but these all involve a significant time investment in setup and
maintenance. If all you care about is `git push` and `git pull`, you probably
already have what you need to spin up a simple Git server.

**All it takes is another machine with an SSH server and a key pair. That's it.**

There are two main setup flows that should feel familiar.

To add a new repository to the remote, first create a bare repo in the desired
location on the remote host:

```
$ mkdir <repo name>
$ cd <repo name>
$ git init --bare
```

Then add the new remote on your development host and push branches you care about (probably `main`):

```
$ git remote add <remote name> <ssh user>@<remote host>:<repo path>
$ git checkout <branch>
$ git push -u <remote name> <branch>
```

Use the same remote URL scheme to clone a repository onto a new development host:

```
$ git clone <ssh user>@<remote host>:<repo path>
```

This simplest setup will work fine for single-user scenarios. For sharing with multiple users,
you'll likely want to [create a dedicated unprivileged `git` user](https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server).

