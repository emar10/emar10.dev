+++ 
draft = false
date = 2022-11-09T16:06:27-05:00
title = "Sous v0.1 Postmortem"
description = "Unveiling what I managed to make for my one month challenge, and a look into the future for Sous"
slug = ""
authors = []
tags = ["projects", "rust", "sous"]
categories = []
externalLink = ""
series = []
+++

October is over, and I'm back for one last challenge-related post. Today will
mark the somewhat arbitrary v0.1 release of Sous. I'll also discuss a bit of my
development process and and my plans for the future of the project.

# Unveiling Sous v0.1

While significantly scaled back from what I had originally hoped to accomplish
in a single month, I hope that the version of Sous I am publicly releasing
today still manages to be a useful tool.

Sous is not currently packaged, but can be installed from
[crates.io](https://crates.io/crates/sous/) using Cargo:

```
$ cargo install sous
```

The CLI essentially accomplishes a single task: ingesting YAML-formatted recipe
files, and outputting them as Markdown. Here's a rundown of the current format:

```yaml
# Recipe name, output as H1 or as title in front matter
name: Foo Bars
# Recipe author
author: Alice Example
# An optional URL source for the recipe
url: https://example.com/foobars
# Number of servings yielded by the recipe as written
servings: 8
# Optional time in minutes estimated for prep
prep_minutes: 10
# Estimated cook time in minutes
cook_minutes: 8

# The list of required ingredients
ingredients:
  # Each ingredient requires a name, and can have an amount and/or unit
  - name: foo
    amount: 5
    unit: cups
  - name: bar
    amount: 2
  - name: baz

# Finally, a string list defines the method for the recipe
steps:
  - Combine foo and bars in a bowl.
  - Frobnicate as desired.
  - Move to a pan and cook over medium heat for 8 minutes.
  - Garnish with baz and serve immediately.
```

The `sous` command only requires a single argument, a path pointing to input
data. Sous can operate in two modes: single file input, which converts a single
YAML recipe into Markdown; or cookbook mode, which batch converts
all recipe files in a directory. The mode is inferred by whether the input path
is a file or a directory.

In single file mode, the output will be sent to `stdout`, and cookbook mode
will create a directory in the PWD called `render` to store output files by
default. The output location can be changed with the `--output` option. The
`--servings` option allows overriding the number of servings in the render
(recalculating ingredient amounts as well), and the `--front-matter` flag
modifies embeds metadata in YAML front-matter appropriate for static site
renderers like Hugo instead of using pure Markdown.

The primary usecase for Sous in its current state is as an intermediate tool to
be used in conjunction with systems that injest Markdown. This allows the
source YAML for recipes to be centrally maintained and rendered for different
end uses.

As an example, I've got a handful of recipes in a YAML cookbook, and a Hugo
website in another directory:

```
$ ls ./cookbook/
beefy-spanish-rice.yml  cinnamon-pancakes.yml  pork-tenderloin.yml
$ ls ./cooksite/
archetypes  config.toml  content  data  layouts  public  resources  static  themes
```

Next, I run the cookbook through Sous, with front-matter enabled and the output
set to the website's content directory:

```
$ sous ./cookbook/ --output ./cooksite/content/posts/ --front-matter
$ ls ./cooksite/content/posts/
beefy-spanish-rice.md  cinnamon-pancakes.md  pork-tenderloin.md
```

The resulting files render nicely in Hugo:

{{<figure src=/images/recipe-manager-postmortem/hugo.png title="Recipe converted from YAML rendered by Hugo with no further edits.">}}


# Looking Forward

While October is over, I do plan to continue working on Sous. I may have grand
plans for major new functionality, but for the near future the core needs some
refinement in a couple of areas.

As things stand, the `sous` library crate is little more than broken out CLI
implementation. The API needs to be rounded out to support more general use
cases, and adhere to common Rust conventions and
[API guidelines](https://rust-lang.github.io/api-guidelines/about.html).

Next on the list is quality documentation, both inline for developers and
external for end users. The library crate *does* currently have some doc
comments, but they are fairly threadbare. Especially in the absence of a
dedicated recipe editor, the Sous YAML recipe format will also need quality
documentation that stays up to date.

Finally, I intend to adopt more DevOps-y processes to solve a handful of
problems. Cargo is a perfectly usable build system, but not a particularly
great end-user package manager. Adding CI/CD along with a comprehensive test
suite will make for a happy repository.

---

October may not have gone as well as I'd hoped, but I'm still pleased with the
results. Rust has been a very pleasant language to work with, I've learned a
lot, and I look forward to continuing my efforts with Sous.

Sous is now available under the MIT license on
[GitHub](https://github.com/emar10/sous/) and
[crates.io](https://crates.io/crates/sous/).

