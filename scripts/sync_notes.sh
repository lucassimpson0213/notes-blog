#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(pwd)"
TMPDIR="$WORKDIR/.repos_tmp"
OWNER="lucassimpson0213"

echo "Cleaning old content..."
rm -rf content/repos
mkdir -p content/repos

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

# Read repos.txt safely (supports last line without newline)
while IFS= read -r repo || [ -n "${repo:-}" ]; do
  # Trim whitespace
  repo="$(echo "${repo:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"

  # Skip blanks and comments
  if [ -z "$repo" ] || [[ "$repo" == \#* ]]; then
    continue
  fi

  NAME="$(basename "$repo")"              # allow either "mb1_memmap" or "path/mb1_memmap"
  TARGET="content/repos/$NAME"
  REPO_DIR="$TMPDIR/$NAME"
  WIKI_DIR="$TMPDIR/${NAME}.wiki"

  echo "Syncing $OWNER/$NAME"
  mkdir -p "$TARGET"

  # ----------------------
  # Clone main repo
  # ----------------------
  MAIN_URL="https://github.com/$OWNER/$NAME.git"
  if git ls-remote "$MAIN_URL" >/dev/null 2>&1; then
    rm -rf "$REPO_DIR"
    git clone --depth 1 "$MAIN_URL" "$REPO_DIR"

    if [ -d "$REPO_DIR/notes" ]; then
      echo "  → copying notes/"
      mkdir -p "$TARGET/notes"
      # copy contents (not the folder itself) so structure is stable
      cp -R "$REPO_DIR/notes/." "$TARGET/notes/" || true
    else
      echo "  → no notes/ folder"
    fi
  else
    echo "  → repo not found: $MAIN_URL"
  fi

  # ----------------------
  # Clone GitHub wiki (separate repo)
  # ----------------------
  WIKI_URL="https://github.com/$OWNER/$NAME.wiki.git"
  if git ls-remote "$WIKI_URL" >/dev/null 2>&1; then
    echo "  → syncing wiki/"
    rm -rf "$WIKI_DIR"
    git clone --depth 1 "$WIKI_URL" "$WIKI_DIR"

    mkdir -p "$TARGET/wiki"
    # Copy all markdown files from wiki repo (keeps subfolders if any)
    find "$WIKI_DIR" -type f -name "*.md" -print0 | while IFS= read -r -d '' file; do
      rel="${file#$WIKI_DIR/}"
      mkdir -p "$TARGET/wiki/$(dirname "$rel")"
      cp "$file" "$TARGET/wiki/$rel"
    done
  else
    echo "  → no wiki repo"
  fi

done < repos.txt

rm -rf "$TMPDIR"
echo "Sync complete."

