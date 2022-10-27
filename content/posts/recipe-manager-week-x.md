+++ 
draft = false
date = 2022-10-26T20:46:51-04:00
title = "Recipe Manager Week X Update"
description = "The last \"weekly\" Sous development update for October 2022"
slug = ""
authors = []
tags = ["projects", "rust", "sous"]
categories = []
externalLink = ""
series = []
+++

It's time for another Sous development update, this post's theme being *"better
late than never."* Truth be told I've been suffering from some wicked burnout
since the previous update, and haven't been left with much energy in my free
time to work on the project. That said, I'm now back in the game for the home
stretch of the month, with some decent progress to chat about today.

# Re-evaluating Goals

A bit of housekeeping, first off. Here's a quick recap of my original goals for
the month:

* A reusable core library implementing data structures, conversions, and
  backend storage.
* A command line frontend for scriptable display and conversion.
* A GUI for everyday browsing and display, with a full-featured editor built-in.

While there is some good progress to show on the former two items, it's pretty
clear at this point that a quality GUI is not in the cards. I likely still
won't be able to achieve the lofty flexibility goals of the core library with
the time I have left in the month, but a usable system and a solid base on
which to continue development is definitely attainable.

# Code Cleanup

As I picked back up on the project, I first took some time to clean things up a
bit.

The core Sous library and the frontend CLI have been separated into separate
Rust modules, with the library further broken into a handful of submodules.
While Sous as a whole isn't large enough yet to warrant separate repositories
(or multiple crates glued together by Cargo's workspace system), this will
allow me to make quick work of that task when the time comes.

As a part of separating the library and binary code, I've adopted some common
Rust error handling practices. All errors that the library expects are now
wrapped in a `SousError` enum, utilizing the well-traveled crate
[thiserror](https://crates.io/crates/thiserror/1.0.24). This allows any
function that may result in an error to return a single `Result` type, leaving
the client code to decide what to do.

# More Structs

The core `Recipe` struct still only contains three fields, but encodes much
more information.

A `Metadata` struct stores the recipe's name, author, serving count, and
estimated cook time. A source URL and estimated prep time can also optionally
be set.

While the method is still internally stored as a simple `Vec<String>`,
ingredients now have their own struct. The only required field is a display
name, with an optional unit and amount included in the render if set.

# Markdown Rendering Options

A new `RenderSettings` struct has been added to control the Markdown output
when rendering a recipe. It currently has options to omit individual sections
and override the default serving yield (which also recalculates ingredient
amounts).

Later on I plan to add options for overriding header text and replacing the
pure Markdown title section with front matter appropriate for tools like static
site generators or Pandoc.

# CLI Trimming and Options

Not a lot of excitement on the CLI side of the world aside from adding options
hooked up to the new rendering settings. In fact, the `main.rs` has been
trimmed down to less than 50 lines.

***

As mentioned earlier, I'm paring down expectations for the end of the month. My
current goal over the next few days is to implement the concept of a cookbook
-- a group of recipes that can be acted upon in bulk. From there I aim to
support converting an entire cookbook into a format that can be ingested by a
different system for prettier rendering (current thoughts are a single PDF via
Pandoc, or a static website with Hugo), and scripting the whole process.

My next update (likely sometime late next week) will serve as a postmortem for
the month, and with my personal challenge done I'll be doing any further
development out in the open.

