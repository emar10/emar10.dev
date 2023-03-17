+++ 
date = 2023-03-16T21:15:50-04:00
title = "Leveraging sous on my website"
description = "In which I add recipes to this website using sous."
slug = ""
tags = ["projects", "sous", "hugo", "podman", "containers"]
+++

I was recently inspired by the [Menu](https://brandonrozek.com/menu/) page on
friend and colleague Brandon Rozek's website to implement something similar
here. I already had a collection of [sous](https://github.com/emar10/sous/)
recipes used to generate a printable PDF, and I figured that using the
templated output feature in 0.3.0 would make this fairly trivial.

# Generating Hugo content pages with sous

First, I added a new `cookbook` section to my Hugo site, with a simple index
page and the necessary snippets to list any pages in that section. Next, I
created a [separate repository](https://github.com/emar10/cookbook/) for my
existing sous recipes[^1] and added it as a submodule. Next, a basic
`recipe.md` template:

[1]: At least, the ones I felt were ready for public consumption.

```markdown
---
title: "{{ name }}"
---

**{{ servings }} servings | {{ prep_minutes }} prep minutes | {{ cook_minutes }} cook minutes**

{% if url %}**Adapted from [{{ author }}]({{ url }})**{% endif %}

## Ingredients

{% for ingredient in ingredients %}* {% if ingredient.amount %}{{ ingredient.amount }} {% endif %}{% if ingredient.unit %}{{ ingredient.unit }} {% endif %}{{ ingredient.name }}
{% endfor %}

## Method

{% for step in steps %}{{ loop.index }}. {{ step }}
{% endfor %}
```

The template populates the `title` field for Hugo, places the rest of the
metadata below (only displaying the author if there is also a source URL
present), and formats the body of the recipe as one would expect.

Finally, to generate the Markdown content pages for Hugo:

```
$ sous -m template -t ./recipe.md -o ./content/cookbook/ ./cookbook/
```

# Integrating sous into the build process

Next, I needed to automate running sous to generate the recipe content pages.
Currently, I build my website as an OCI image that gets deployed with Podman.
Using the official Rust image as a base, getting a working copy of sous to do
this with is easy:

```dockerfile
FROM docker.io/rust:1.68 as sous

RUN cargo install --version ~0.3 sous
COPY ./cookbook /cookbook
COPY ./recipe.md /recipe.md
RUN sous -m template -t recipe.md -o output/ cookbook/
```

The Hugo stage can then grab the generated files before building:

```dockerfile
FROM docker.io/alpine:edge as hugo

RUN apk add hugo
RUN hugo version

COPY . /src
COPY --from=sous /output/* /src/content/cookbook/
WORKDIR /src
RUN hugo --minify
```

---

While I'm largely pleased with how I've set this up, the Containerfile does
leave some room for optimization in a few ways. Most notably, building sous
from source is a fairly expensive operation to perform on every website update.
To alleviate this I'll likely create a separate image for this purpose.

In any case, a handful of recipes are now available in the
[Cookbook](/cookbook/) section, with more to come as I clean up more of my
existing ones for publishing.

