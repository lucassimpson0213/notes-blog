#!/usr/bin/env bash
set -e

WORKDIR=$(pwd)
TMPDIR="$WORKDIR/.repos_tmp"

echo "Cleaning old content..."
rm -rf content/repos
mkdir -p content/repos

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

while read repo; do
    echo "Syncing $repo"

    NAME=$(basename "$repo")
    TARGET="content/repos/$NAME"

    git clone --depth 1 "https://github.com/$repo.git" "$TMPDIR/$NAME"

    mkdir -p "$TARGET"

    # notes folder
    if [ -d "$TMPDIR/$NAME/notes" ]; then
        echo "  → copying notes/"
        cp -r "$TMPDIR/$NAME/notes" "$TARGET/"
    fi

    # wiki folder
    if [ -d "$TMPDIR/$NAME/wiki" ]; then
        echo "  → copying wiki/"
        cp -r "$TMPDIR/$NAME/wiki" "$TARGET/"
    fi

done < repos.txt

rm -rf "$TMPDIR"

echo "Sync complete."

