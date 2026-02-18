#!/usr/bin/env bash
set -euo pipefail

WORKDIR="$(pwd)"
TMPDIR="$WORKDIR/.repos_tmp"
OWNER="lucassimpson0213"
BASE="content/posts"   # <-- everything becomes posts

echo "Cleaning old synced content..."
rm -rf "$BASE/repos"
mkdir -p "$BASE/repos"

rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

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
  # created = first commit touching file, updated = last commit touching file
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

# Read repos.txt safely
while IFS= read -r repo || [ -n "${repo:-}" ]; do
  repo="$(echo "${repo:-}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  if [ -z "$repo" ] || [[ "$repo" == \#* ]]; then
    continue
  fi

  NAME="$(basename "$repo")"
  TARGET="$BASE/repos/$NAME"      # <-- under posts
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

      find "$REPO_DIR/notes" -type f -name "*.md" -print0 | while IFS= read -r -d '' src; do
        rel="${src#$REPO_DIR/notes/}"
        mkdir -p "$TARGET/notes/$(dirname "$rel")"
        cp "$src" "$TARGET/notes/$rel"
        inject_frontmatter_from_repo "$REPO_DIR" "$src" "$TARGET/notes/$rel" "$NAME"
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
    echo "  → syncing wiki/"
    rm -rf "$WIKI_DIR"
    git clone --depth 1 "$WIKI_URL" "$WIKI_DIR"

    mkdir -p "$TARGET/wiki"
    find "$WIKI_DIR" -type f -name "*.md" -print0 | while IFS= read -r -d '' src; do
      rel="${src#$WIKI_DIR/}"
      mkdir -p "$TARGET/wiki/$(dirname "$rel")"
      cp "$src" "$TARGET/wiki/$rel"
      inject_frontmatter_from_repo "$WIKI_DIR" "$src" "$TARGET/wiki/$rel" "$NAME"
    done
  else
    echo "  → no wiki repo"
  fi

done < repos.txt

echo "Generating section indexes..."

# root repos section
mkdir -p content/posts/repos
cat > content/posts/repos/_index.md <<EOF
+++
title = "Repository Notes"
sort_by = "date"
+++
Automatically synced notes and wiki pages from my GitHub repositories.
EOF

# per-repo indexes
for repo_dir in content/posts/repos/*; do
  [ -d "$repo_dir" ] || continue
  repo_name="$(basename "$repo_dir")"

  cat > "$repo_dir/_index.md" <<EOF
+++
title = "$repo_name"
sort_by = "date"
+++
Notes and documentation for $repo_name.
EOF

  if [ -d "$repo_dir/wiki" ]; then
    cat > "$repo_dir/wiki/_index.md" <<EOF
+++
title = "$repo_name Wiki"
sort_by = "date"
+++
Wiki documentation synced from GitHub.
EOF
  fi

  if [ -d "$repo_dir/notes" ]; then
    cat > "$repo_dir/notes/_index.md" <<EOF
+++
title = "$repo_name Notes"
sort_by = "date"
+++
Development notes and learning logs.
EOF
  fi
done

rm -rf "$TMPDIR"
echo "Sync complete."

