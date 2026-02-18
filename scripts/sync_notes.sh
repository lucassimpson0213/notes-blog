#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(pwd)"
TMPDIR="$WORKDIR/.repos_tmp"
OWNER="lucassimpson0213"
BASE="content/posts"

echo "Cleaning old synced content (flat posts)..."
# delete only previously-synced flat posts (keeps your real blog posts)
find "$BASE" -maxdepth 1 -type f -name "*__wiki__*.md" -delete 2>/dev/null || true
find "$BASE" -maxdepth 1 -type f -name "*__notes__*.md" -delete 2>/dev/null || true

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"
mkdir -p "$BASE"

inject_frontmatter_from_repo() {
  local src_repo_dir="$1"   # cloned repo path
  local src_file="$2"       # file inside that repo (absolute)
  local dest_file="$3"      # file in Zola content (absolute)
  local repo_name="$4"      # repo slug/name

  # Skip empty/non-file
  [ -f "$dest_file" ] || return 0
  [ -s "$dest_file" ] || return 0

  local first
  first="$(head -n 1 "$dest_file" || true)"
  if [[ "$first" == "+++" ]] || [[ "$first" == "---" ]]; then
    return 0
  fi

  # title: prefer H1, else filename
  local h1 base title title_esc
  h1="$(grep -m1 -E '^\# ' "$dest_file" | sed 's/^# *//' || true)"
  base="$(basename "$dest_file" .md | sed 's/[-_]/ /g')"
  title="${h1:-$base}"
  title_esc="$(printf '%s' "$title" | sed 's/"/\\"/g')"

  # dates from SOURCE repo history
  local rel created updated today
  today="$(date +%Y-%m-%d)"
  rel="${src_file#$src_repo_dir/}"

  created="$(git -C "$src_repo_dir" log --follow --diff-filter=A --format=%as -- "$rel" 2>/dev/null | tail -n 1 || true)"
  updated="$(git -C "$src_repo_dir" log -1 --format=%as -- "$rel" 2>/dev/null || true)"
  created="${created:-$today}"
  updated="${updated:-$today}"

  local tmp
  tmp="$(mktemp)"
  cat > "$tmp" <<EOF
+++
title = "$title_esc"
date = $created
updated = $updated



+++

EOF
  cat "$dest_file" >> "$tmp"
  mv "$tmp" "$dest_file"
}

# Copy a markdown file as a flat post, with path encoded into the filename
copy_as_flat_post() {
  local src_repo_dir="$1"   # e.g. /tmp/repo or /tmp/repo.wiki
  local src_file="$2"       # absolute path to md file
  local repo_name="$3"      # e.g. sys-userland-kernel-rust
  local kind="$4"           # "notes" or "wiki"

  local rel dir base slug dest

  # rel path within src repo
  rel="${src_file#$src_repo_dir/}"
  dir="$(dirname "$rel")"
  base="$(basename "$rel" .md)"

  # flatten: repo__kind__path__file
  if [ "$dir" = "." ]; then
    slug="${repo_name}__${kind}__${base}"
  else
    slug="${repo_name}__${kind}__$(echo "$dir" | sed 's/\//__/g')__${base}"
  fi

  # normalize slug: lowercase, keep a-z0-9 and __, convert others to -
  slug="$(echo "$slug" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]/-/g')"

  dest="$BASE/${slug}.md"

  cp "$src_file" "$dest"
  inject_frontmatter_from_repo "$src_repo_dir" "$src_file" "$dest" "$repo_name"
}

# Read repos.txt safely
while IFS= read -r repo || [ -n "${repo:-}" ]; do
  repo="$(echo "${repo:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -z "$repo" ] || [[ "$repo" == \#* ]]; then
    continue
  fi

  NAME="$(basename "$repo")"
  REPO_DIR="$TMPDIR/$NAME"
  WIKI_DIR="$TMPDIR/${NAME}.wiki"

  echo "Syncing $OWNER/$NAME"

  # ----------------------
  # Clone main repo
  # ----------------------
  MAIN_URL="https://github.com/$OWNER/$NAME.git"
  if git ls-remote "$MAIN_URL" >/dev/null 2>&1; then
    rm -rf "$REPO_DIR"
    git clone --depth 1 "$MAIN_URL" "$REPO_DIR"

    if [ -d "$REPO_DIR/notes" ]; then
      echo "  → copying notes/ as flat posts"
      find "$REPO_DIR/notes" -type f -name "*.md" -print0 | while IFS= read -r -d '' src; do
        copy_as_flat_post "$REPO_DIR" "$src" "$NAME" "notes"
      done
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
    echo "  → copying wiki as flat posts"
    rm -rf "$WIKI_DIR"
    git clone --depth 1 "$WIKI_URL" "$WIKI_DIR"

    find "$WIKI_DIR" -type f -name "*.md" -print0 | while IFS= read -r -d '' src; do
      copy_as_flat_post "$WIKI_DIR" "$src" "$NAME" "wiki"
    done
  else
    echo "  → no wiki repo"
  fi

done < repos.txt

rm -rf "$TMPDIR"
echo "Sync complete."

