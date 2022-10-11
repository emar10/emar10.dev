+++ 
draft = true
date = 2022-10-11T15:42:06-04:00
title = "Recipe Manager Week 1 Update"
description = ""
slug = ""
authors = []
tags = ["projects", "rust", "recipe manager"]
categories = []
externalLink = ""
series = []
+++

Happy ~~Monday~~ Tuesday, and welcome to the first development update for my
recipe manager, tentatively named *Sous*. There are a few things to cover,
including the chosen development environment, the beginnings of the core
library, and a basic first client.

# Development Environment

To step a little out of my comfort zone, I've chosen to build Sous using Rust.
I would have far more experience with C/C++, C#, or Python, but Rust makes an
interesting value proposition[^1] and I've been meaning to give it a try for a
larger project for a while.

# Core Library

Currently the core of Sous consists of a single naive `Recipe` data structure:

```rust
#[derive(Serialize, Deserialize, Debug)]
struct Recipe {
    name: String,
    steps: Vec<String>,
    ingredients: Vec<String>,
}
```

This struct represents a recipe similarly to how one would using a standard
text editor or note application, containing only a name and two lists of
strings for the ingredients/method. This affords the user a decent amount of
flexibility in how to express recipes, but encodes very little information
readily available to the application.

The [`serde`](https://serde.rs/) and
[`serde_yaml`](https://github.com/dtolnay/serde-yaml) crates allow recipes to
be easily stored/loaded in YAML format, though a more maintainable solution
will likely be required as the library grows.[^2]

# Sous CLI

To demonstrate this early functionality I've created a basic first CLI for Sous
that can ingest a YAML-formatted recipe file and output a simple Markdown
representation either to standard output or a file. It makes use of the
excellent [`clap`](https://github.com/clap-rs/clap) crate to implement command
line arguments with a simple struct:

```rust
#[derive(Parser, Debug)]
#[command()]
struct Args {
    /// YAML-formatted recipe to convert
    #[arg()]
    file: PathBuf,

    /// Output file
    #[arg(short, long)]
    output: Option<PathBuf>,
}
```

As an example, `sous tenderloin.yml -o tenderloin.md` with this YAML:

```yaml
---

name: Pork Tenderloin
ingredients:
  - 1 tenderloin
  - 1 tablespoon Italian seasoning
  - Salt
  - Pepper
  - Olive oil
steps:
  - Preheat oven to 400°F.
  - Pat tenderloin dry with a paper towel.
  - Cover tenderloin with Italian seasoning, salt, and pepper.
  - Coat the bottom of an oven-safe pan with olive oil and put over medium-high heat until shimmering.
  - Sear the tenderloin, turning occasionally, for about 8 minutes or until well browned.
  - Remove pan from heat and place in oven for 20 minutes or until an internal temperature of 145°F is reached.
  - Remove from oven and loosely tent with foil, allowing to rest for at least 5 minutes before cutting and serving.
```

outputs the following Markdown:

```markdown
# Pork Tenderloin

## Ingredients
* 1 tenderloin
* 1 tablespoon Italian seasoning
* Salt
* Pepper
* Olive oil

## Method
1. Preheat oven to 400°F.
2. Pat tenderloin dry with a paper towel.
3. Cover tenderloin with Italian seasoning, salt, and pepper.
4. Coat the bottom of an oven-safe pan with olive oil and put over medium-high heat until shimmering.
5. Sear the tenderloin, turning occasionally, for about 8 minutes or until well browned.
6. Remove pan from heat and place in oven for 20 minutes or until an internal temperature of 145°F is reached.
7. Remove from oven and loosely tent with foil, allowing to rest for at least 5 minutes before cutting and serving.
```

Not the most exciting conversion, but it works!

[^1]: Current kernel-related drama aside.
[^2]: Serde will likely be used for communication between Sous instances in
  this case.

