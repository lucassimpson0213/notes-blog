#!/usr/bin/env bash
set -e

FILE="$1"
REPO="$2"

# ---- SAFETY CHECKS ----
if [ -z "$FILE" ]; then
    echo "Skipping empty filename"
    exit 0
fi

if [ ! -f "$FILE" ]; then
    echo "Skipping non-file: $FILE"
    exit 0
fi

# -----------------------

# Check if frontmatter already exists
FIRSTLINE=$(head -n 1 "$FILE" || true)

if [[ "$FIRSTLINE" == "+++" ]]; then
    exit 0
fi

# Generate title from filename
BASENAME=$(basename "$FILE" .md)
TITLE=$(echo "$BASENAME" | sed 's/[-_]/ /g')

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

