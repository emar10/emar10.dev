---
title: "Export Slack Emoji"
date: 2024-08-25T10:51:00-04:00
draft: false
description: "In which I reclaim a large number of cheap memes with minimal effort, though probably still more than they're worth."
tags: ["json", "bash"]
---

Recently I had cause to want to back up the large number of custom Slack emoji
used in a workspace I'm a part of. Turns out, Slack doesn't provide an official
way to do this. I saw plenty of blog posts and Gists on the subject, but Slack
seems to have thwarted all of their methods (intentionally or otherwise). Here
I'll document the general process I used for backing up nearly a thousand
custom emoji, in a way that I hope proves evergreen.[^1]

As a prerequisite, be sure to log into the target workspace in a browser, where
we have easy access to developer features.

[^1]: Or we get the good ending, where Slack adds a nice Export button to the
    emoji settings page and this whole thing is moot.

# Grab some JSON

Clientside, custom emoji are described using a blob of JSON metadata containing
names and URLs pointing directly to the image files. All we have to do is find
it.

I used the Custom Emoji page within the Workspace Settings, but any page that
displays all custom emoji should do, even just opening the picker in a chat
window and scrolling the list. Whatever the method, next open the browser's
developer tools to look at network requests (for Firefox, `Ctrl-Shift-E` will
open the Network tab). Refresh the page and perform only the interactions
necessary to display the custom emoji, this will hopefully limit the size of
the haystack we'll be searching.

Filter the of network requests down to GETs on JSON files, then look for ones
that contain a list of entries with the data we need: emoji names, and links to
image files. In my case I landed on `emoji.adminList.json`, which paginates
items 100 at a time over multiple requests to the same path. There was a
helpful `paging` object to keep track of which page was which.

# Grab some emoji

I wound up with a series of JSON files with the following format (extraneous
objects omitted):

```json
{
  "emoji": [
    { "name": "wow", "url": "https://emoji.slack-edge.com/<...>" }
  ]
}
```

Given this, I whipped up a quick Bash script leveraging the all-powerful `jq`
and `curl` utilities to download each image and rename it based on the display
name:

```bash
#!/bin/bash

target_path=emoji

mkdir -p "$target_path"

# Get a list of all items in the emoji list, jq -c ensures that each line is a
# single item
items=$(jq -c '.emoji[]')

rowcount=$(echo "$items" | wc -l)
rowcurrent=0
failures=0

# Set an empty IFS to prevent separating on spaces, then read -r to iterate
# over lines
echo "$items" | while IFS= read -r item; do
    # Grab name and URL for the emoji, jq -r to avoid extra quotes
    name=$(echo "$item" | jq -r '.name')
    url=$(echo "$item" | jq -r '.url')

    # Parameter expansion magic to trim everything but the extension
    extension="${url##*.}"
    target_file="$target_path/$name.$extension"

    echo "Downloading '$target_file' ($((rowcurrent + 1)) of $rowcount)..."
    curl -so "$target_file" "$url"
    if [ $? -ne 0 ]; then
        >&2 echo "Failed to download $url"
        failures=$((failures + 1))
    fi

    rowcurrent=$((rowcurrent + 1))
done

echo "Successfully downloaded $((rowcount - failures)) of $rowcount emoji."
```

A quick `$ ./slackbak.sh < emoji.adminList.json` call and I had a big stack of
image files. I wouldn't call it robust by any stretch of the word, but it
works.

For future readers, there's a good chance that you'll be looking at a different
JSON structure. The general gist is this: first grab the list of emoji. Next,
for each item, extract the display name and the URL. The URL will almost
definitely have a meaningless to humans ID for a filename, so use the extracted
name and file extension to create a new one. Finally, download the file and
you're off to the races. Just about every language on the planet has a JSON
parser and HTTP client, so don't overthink the implementation; just use
whatever you're most comfortable with, get your emotes, and get on with your
day. Good luck!

