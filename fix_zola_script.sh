#!/usr/bin/env bash
set -euo pipefail

# Fix Zola "stream did not contain valid UTF-8" by:
# - removing .DS_Store everywhere
# - moving binary/media files OUT of content/ into static/assets/
# - adding .DS_Store + Thumbs.db to .gitignore
# - printing a mapping so you can update markdown links
#
# Usage:
#   ./fix_zola_utf8.sh
#
# Notes:
# - This does NOT rewrite your markdown links automatically (it prints what moved).
# - It preserves relative subfolders under content/ inside static/assets/content/.

ROOT="$(pwd)"
CONTENT_DIR="$ROOT/content"
STATIC_DIR="$ROOT/static"
DEST_ROOT="$STATIC_DIR/assets/content"

mkdir -p "$DEST_ROOT"

echo "==> 1) Removing .DS_Store files..."
find "$ROOT" -name ".DS_Store" -print -delete || true

echo "==> 2) Ensuring .gitignore blocks OS junk..."
touch "$ROOT/.gitignore"
if ! grep -qxF '.DS_Store' "$ROOT/.gitignore"; then
  echo ".DS_Store" >> "$ROOT/.gitignore"
fi
if ! grep -qxF 'Thumbs.db' "$ROOT/.gitignore"; then
  echo "Thumbs.db" >> "$ROOT/.gitignore"
fi

echo "==> 3) Moving binary/media files out of content/ ..."

# File extensions that should NOT live in content/
# Add more if needed.
EXTS=(
  png jpg jpeg gif webp svg
  mp4 mov webm mp3 wav flac
  pdf zip tar gz tgz bz2 xz 7z
  ico
)

# Build a find expression like: \( -iname "*.png" -o -iname "*.jpg" ... \)
FIND_EXPR=()
for ext in "${EXTS[@]}"; do
  FIND_EXPR+=(-iname "*.${ext}" -o)
done
unset 'FIND_EXPR[${#FIND_EXPR[@]}-1]' # drop trailing -o

# Collect candidates
FILES=()
while IFS= read -r -d '' f; do
  FILES+=("$f")
done < <(find "$CONTENT_DIR" -type f \( "${FIND_EXPR[@]}" \) -print0 2>/dev/null || true)

if (( ${#FILES[@]} == 0 )); then
  echo "No binary/media files found inside content/. 👍"
else
  echo "Found ${#FILES[@]} binary/media file(s) in content/. Moving them to: $DEST_ROOT"
  echo
  echo "Moved files mapping (update your markdown to use /assets/content/...):"
  echo "-------------------------------------------------------------------"

  for src in "${FILES[@]}"; do
    rel="${src#$ROOT/}"                 # e.g. content/posts/img.png
    rel_under_content="${rel#content/}" # e.g. posts/img.png
    dest="$DEST_ROOT/$rel_under_content"

    mkdir -p "$(dirname "$dest")"

    # If destination exists, avoid clobbering: append a numeric suffix.
    if [[ -e "$dest" ]]; then
      base="$(basename "$dest")"
      dir="$(dirname "$dest")"
      name="${base%.*}"
      ext="${base##*.}"
      i=1
      while [[ -e "$dir/${name}_$i.$ext" ]]; do
        i=$((i+1))
      done
      dest="$dir/${name}_$i.$ext"
    fi

    mv "$src" "$dest"
    echo "$rel  ->  ${dest#$ROOT/}"
  done

  echo "-------------------------------------------------------------------"
  echo
  echo "Tip: In Zola markdown, reference moved assets with absolute paths like:"
  echo "  ![](/assets/content/posts/digitallogic/circuit1.png)"
fi

echo "==> 4) Removing any now-empty dirs under content/..."
find "$CONTENT_DIR" -type d -empty -print -delete 2>/dev/null || true

echo "==> Done."
echo
echo "Next steps:"
echo "  1) git status"
echo "  2) Commit the changes"
echo "  3) Update markdown links to the new /assets/content/... paths (see mapping above)"

