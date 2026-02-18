#!/usr/bin/env bash

FILE="$1"
REPO="$2"

# check if frontmatter already exists
FIRSTLINE=$(head -n 1 "$FILE")

if [[ "$FIRSTLINE" == "+++" ]]; then
    exit 0
fi

TITLE=$(basename "$FILE" .md)
TITLE=$(echo "$TITLE" | sed 's/-/ /g' | sed 's/_/ /g')

DATE=$(date +%Y-%m-%d)

TMPFILE=$(mktemp)

cat <<EOF > "$TMPFILE"
+++
title = "$TITLE"
date = $DATE
updated = $DATE
[taxonomies]
repo = ["$REPO"]
+++

EOF

cat "$FILE" >> "$TMPFILE"
mv "$TMPFILE" "$FILE"

