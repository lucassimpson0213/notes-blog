#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"
REPO="${2:-unknown}"

# Safety checks
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Skip empty files
if [ ! -s "$FILE" ]; then
  exit 0
fi

# Already has TOML or YAML frontmatter?
first="$(head -n 1 "$FILE" || true)"
if [[ "$first" == "+++" ]] || [[ "$first" == "---" ]]; then
  exit 0
fi

# Title: prefer first Markdown H1, else filename
h1="$(grep -m1 -E '^\# ' "$FILE" | sed 's/^# *//' || true)"
base="$(basename "$FILE" .md | sed 's/[-_]/ /g')"
title="${h1:-$base}"

# Use git dates if available, else today
# (works inside your Zola repo checkout)
created="$(git log --follow --diff-filter=A --format=%as -- "$FILE" 2>/dev/null | tail -n 1 || true)"
updated="$(git log -1 --format=%as -- "$FILE" 2>/dev/null || true)"
today="$(date +%Y-%m-%d)"
date="${created:-$today}"
upd="${updated:-$today}"

tmp="$(mktemp)"

cat > "$tmp" <<EOF
+++
title = "$(printf '%s' "$title" | sed 's/"/\\"/g')"
date = $date
updated = $upd

[taxonomies]
repo = ["$REPO"]
+++

EOF

cat "$FILE" >> "$tmp"
mv "$tmp" "$FILE"

