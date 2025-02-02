+++ 
draft = false
date = 2025-02-02T16:00:00
title = "Blogging question challenge, January 2025"
description = "In which I'm prompted to metapost about how I do this blog thing (poorly)."
slug = ""
authors = []
tags = []
categories = []
externalLink = ""
series = []
+++

So I hear I've been tagged to partake in a blogging question challenge started
over on [Bear Blog][1] by [Ava][2] (and later adapted for blogging in general
by [Kev Quirk][3]). I hadn't heard of Bear before, but I like the vibe. It
reminds me a lot of the best parts of my earliest days on the Internet. A lot
of these questions open up discussion points that I wouldn't be likely to bring
up otherwise[^1], so I'm excited to give this a shot.

Thanks to friend and colleague [Brandon][4] for tagging me! I encourage readers
to check out his post and take a walk up/down the tag chain.

[1]: https://bearblog.dev/
[2]: https://blog.avas.space/bear-blog-challenge/
[3]: https://kevquirk.com/blog/blog-questions-challenge
[4]: https://brandonrozek.com/blog/blog-question-challenge-jan2025/

[^1]: Which, I suspect, *may be the point*.

## Why did you start blogging in the first place?

Truth be told, I'm not quite sure why I started blogging. Before, my personal
site mostly just existed as something to host my resume on.[^2] But now the
blog is more valuable to me as a space to write what I please and hone my
craft. This is the perfect place to self-reflect on projects as I'm working on
them. I can document little tricks I've used to implement something that I'd
certainly forget otherwise. It's pretty much just for my own benefit at the end
of the day, but if a post of mine happens to be helpful to someone else, all
the better.

[^2]: And to put in my resume. Look at me, I've got the know-how to deploy some
    HTML!

## What platform are you using to manage your blog and why did you choose it?

I currently use [Hugo][5], a Go-based static site generator. It has great
theming support, lets me use version control systems I'm already comfortable
with, and the build output is just static HTML that runs fast and is dead
simple to deploy.

[5]: https://gohugo.io/

At time of writing, this site is hosted on [Linode][6][^3]. It's not the
cheapest VPS around, but it's inexpensive and the feature set is good.

[6]: https://linode.com/

Another tool involved in my website is my tiny recipe manager, [Sous]. Recipes
are included as a Git submodule, then turned into Hugo pages during build. It's
slightly out of date, but I made a more detailed post on this topic
[here][7].

[7]: /posts/sous-with-hugo/

[^3]: Or *Akamai Connected Cloud* these days, I guess.

## Have you blogged on other platforms before?

I'd previously used [Jekyll][8] for many of the same reasons that I currently
use Hugo. However, it requires a full Ruby environment to run, and I'm very
much not a Ruby developer. That said, I didn't really blog at the time.

[8]: https://jekyllrb.com/

## How do you write your posts?

From a tech stack perspective, I've been a fervent (neo)Vim user for somewhere
in the ballpark of a decade. Right now I'm using [LazyVim][9], an excellent
Neovim distribution that leverages the coolest of the cool new plugins on the
block. But Hugo just uses Markdown, and Markdown is generally nice to work
with, whatever the tool at play. I could boot up a DOS machine and use good ol'
`EDIT.COM` and I wouldn't have *that* bad of a time.

As for my writing process, that varies wildly. For some posts[^4], I just start
with a topic and put words to keyboard until I feel like there's enough. And
some posts don't need anything more than that. Recently though I've made more
of an effort to outline posts.[^5]

[9]: https://www.lazyvim.org/

[^4]: Mostly older ones.
[^5]: This one was easy, the outline was already done for me!

## When do you feel most inspired to write?

I'm almost guaranteed to be inspired to write a post whenever I'm working on a
project, particularly if I'm doing some odd configuration or complicated
deployment that I'd be likely to forget down the line. That said, if my post
count is any indication, inspiration doesn't correlate very strongly to
actually publishing something.

## Do you publish immediately after writing, or do you let it simmer a bit as a draft?

This varies, mostly based on the length of the post. For short topics, I'll
frequently commit a post and send it up for publishing right away. Longer posts
will get some extra proofreading though. As a failsafe, I've built in about an
hour delay before my web server actually pulls new content.

## What's your favorite post on your blog?

That would probably be the one where I talk about [bulk exporting Slack
emotes][10]. Not necessarily for the content of the post, but more for the
flow of writing it. I did the thing that inspired the post, decided to write a
post about it, and just... did. It was published within a day, and it felt
effortless. That's the kind of feeling I'd like to capture here more often.

[10]: posts/export-slack-emoji/

## Any future plans for your blog?

First off, I'm aiming to finally manage a post count for the year above the
single digits. At any given time I've got too many ideas floating around for
posts and don't execute often enough. This feels like a good start, so we'll
see where that takes me.

More specifically for the near future, I plan to write a few posts about the Go
programming language. I'd like to dive in, learn a bit, and challenge myself to
make something useful within a week or two. I enjoyed doing a similar challenge
for Rust a few years back, if things go well I might try to make this a
properly recurring endeavor.

---

Once again, thanks to [Brandon][4] for tagging me here. I'm not a regular in
the blogosphere, so I might wind up being a leaf here, but perhaps I can get
[Patrick][11] to dust off his blog?

[11]: https://blog.patrickgatewood.com/
