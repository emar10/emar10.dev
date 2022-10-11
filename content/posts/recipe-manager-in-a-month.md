+++ 
draft = false
date = 2022-10-03T16:07:39-04:00
title = "Creating a Recipe Manager in a Month"
description = ""
slug = ""
authors = []
tags = ["projects", "recipe manager"]
categories = []
externalLink = ""
series = []
+++

It is October, that wonderful time of the year where a certain cloud provider
dispenses t-shirts in exchange for potentially dubious pull requests. This year
I've decided to give myself a challenge: to design and build an open source
recipe management system before the month is out.

# The Why

Why do this? My reasoning is three-fold:

First, I haven't built anything for myself in quite some time. This will be an
excellent way to try out some different technologies and enjoy a change of pace
from my day job.

Second, tracking the progress of development will be a great motivator to write
more blog posts.

Finally, I just want a good recipe manager!

# The Rules

Time-wise, I'm beginning work as this blog post goes live, and aim to "deliver"
a working product by the end of the day on October 31.

I'll also be playing with Hackathon-style rules as far as prior work goes. No
design documents, no code, nothing but ideas floating in my head until the
challenge begins.

Each week (most likely on Mondays) I'll post a development update on my blog,
followed by a postmortem on the whole experience in early November.

# The Goals

Now on to the fun stuff, exactly what I intend to make. Many recipe managers
currently available are basically just glorified notepads. You might get some
fancy formatting, but at the end of the day you've still just got the same
information you'd have on a physical recipe card. A name, a list of
ingredients, and a list of instructions; just a bunch of text strings.

I'd like to create a system that encodes more useful information and allows a
frontend to infer a lot more; things like sensible serving adjustments,
equipment needed, what steps require active attention and what ones leave the
cook free to do other tasks.

Naturally I'd like to build something that I can continue to improve over time,
but for the purposes of this challenge I also need a clearly defined end state.
This may get tweaked as the month goes on, but at time of writing I hope to
finish the month with the following:

* A reusable core library implementing the basic data structures, operations,
  and a backend storage model.
* A handful of command-line utilities for basic display, conversion, and
  basic editing of recipes.
* A simple GUI application for everyday browsing and display, with a
  full-featured editor built in.

I think I've set some perfectly reasonable goals for myself here, but whatever
the case I'll be back next week with the first development update!

