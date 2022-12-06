+++ 
date = 2022-12-05
title = "Sous 0.2 Development Update"
description = "A quick post on the second release of Sous."
tags = ["projects", "rust", "sous"]
+++

I've been continuing development on Sous since the initial version, and
yesterday version 0.2 was released. This update doesn't include any exciting
CLI changes, instead focusing on refining the core library to ease future
development. In this quick post I'll be discussing some of the more notable
changes along with expectations for the next release.

---

A good portion of the work for 0.2 revolved around repository housekeeping.
This included documentation, testing, and CI/CD.

Good documentation is important for any software, and Sous 0.1 was sorely
lacking. The previously unhelpful README was populated with some general
information and usage instructions, while inline documentation comments were
added to provide more detailed API information. A CHANGELOG was also
implemented, using a slightly modified format from 
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

A modest test suite was created to cover the higher impact portions of the
public API, along with a larger example code snippet in the crate level
documentation testing the YAML to Markdown workflow. While testing will need
some additional work down the line, this should allow me to quickly catch any
major breakages with new code.

When implementing CI/CD, I chose to use GitHub Actions. It's not exactly my
favorite platform to use, but it's dead simple. No integration work, no messing
around with credentials, just drop some workflow files in a magic `.github`
directory and off it goes. I may look elsewhere down the line, but for now
it'll do. As for the actual workflows, one (contributed by friend and colleague
[Stefano](https://github.com/scoronado12) from my days as a student) runs all
available tests and lints with `rustfmt`[^1] on all pushes/PRs, while a second
workflow builds and publishes a new version on crates.io whenever a GitHub
release is created.

[^1]: Admittedly the latter check bit me on a couple of occasions when I forgot
      to run the formatter locally before committing. Methinks a Git hook may
      be in order.

---

Now, onto the good stuff. The most consequential change in this release was the
separation of the previously monolithic `recipe` module. The `Ingredient` and
`Metadata` types were migrated to their own modules. `Recipe` and its subtypes
are now treated more as the simple data structs they are, exposing their fields
as `pub` and implementing common standard library traits.

`Recipe::to_markdown()` and `Recipe::to_file()` were part of a design that
would not have scaled well at all. Supporting additional formats in the same
way would have quickly led to a bloated `impl` block. `RenderSettings`
presented a similar issue, containing options specific to the Markdown format.

To solve this, a simple `Renderer` trait was added:

```rust
pub trait Renderer {
    fn render(&self, recipe: &Recipe) -> String;
}
```

Now, new output formats can be more cleanly added, and users of the crate can
implement their own renderers in the same way. `RenderSettings` was renamed to
`Markdown`, and modified to implement this trait. Now left redundant, the
output functions in `Recipe` were removed. 

---

My aim is for 0.3 to be another release focused mostly around API improvements.
The `cookbook` module is up for a redesign so that different bulk storage
methods can be supported down the line. I would also like to begin support for
importing different recipe formats, starting with
[Schema.org](https://schema.org/Recipe)'s. Finally, adding support for
outputting recipes using a templating engine à la Jinja. Naturally, the CLI
will also be updated to leverage these new library features.

