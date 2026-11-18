#!/bin/sh
# Schema 2: notes link up to one parent, so Obsidian's graph is a tree (GANDALF.md §8), and the graph gets
# colour groups. Project notes: "Group: …" becomes "Up: …" (to [[gandalf]] without a group). Group notes get
# "Up: [[gandalf]]". The graph's colour groups are set only when it has none. Idempotent.
# Usage: 2.sh <instance folder>
set -eu
rb="${1:?usage: 2.sh <instance folder>}/red-book"
seed="$(cd "$(dirname "$0")/.." && pwd -P)/seed/red-book/.obsidian/graph.json"

# rewrite <file> <awk program>: replace the file only when the program changed it.
rewrite() {
  awk "$2" "$1" > "$1.tmp"
  if cmp -s "$1" "$1.tmp"; then rm -f "$1.tmp"; else mv "$1.tmp" "$1"; fi
}

for d in "$rb"/projects/*/; do
  f="$d$(basename "$d").md"
  [ -f "$f" ] || continue
  rewrite "$f" '
    !done && /^Group: none( · |$)/ {sub(/^Group: none/, "Up: [[gandalf]]"); done=1}
    !done && /^Group: \[\[groups\// {sub(/^Group: /, "Up: "); done=1}
    {print}'
  grep -q '^Up: ' "$f" || rewrite "$f" '{print} !done && /^# / {print ""; print "Up: [[gandalf]]"; done=1}'
done

for d in "$rb"/groups/*/; do
  f="$d$(basename "$d").md"
  [ -f "$f" ] || continue
  grep -q '^Up: ' "$f" && continue
  rewrite "$f" '
    !done && /^Shared by this group.s projects\. Rules: / {
      r=$0; sub(/^.*Rules: /, "", r); print "Up: [[gandalf]] · Rules: " r; print ""; print "Shared by this group'"'"'s projects."; done=1; next}
    {print}'
  grep -q '^Up: ' "$f" || rewrite "$f" '{print} !done && /^# / {print ""; print "Up: [[gandalf]]"; done=1}'
done

g="$rb/.obsidian/graph.json"
if [ -f "$g" ] && [ -f "$seed" ] && grep -q '"colorGroups": *\[ *\]' "$g"; then
  # Through the environment, not awk -v, which would turn the JSON's \" escapes into bare quotes.
  CG=$(grep '"colorGroups"' "$seed" | sed 's/^ *"colorGroups": *//; s/, *$//') \
    awk '/"colorGroups": *\[ *\]/ {sub(/\[ *\]/, "@CG@"); i = index($0, "@CG@"); $0 = substr($0, 1, i - 1) ENVIRON["CG"] substr($0, i + 4)} {print}' \
    "$g" > "$g.tmp" && mv "$g.tmp" "$g"
fi
exit 0
