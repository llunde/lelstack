#!/bin/sh
# Schema 2: notes link up to one parent, so Obsidian's graph is a tree (GANDALF.md §8), and the graph gets
# colour groups. Project notes: "Group: …" becomes "Up: …", to the group (from the line's link, else the
# `group:` property) or [[gandalf]] without one. Group notes get "Up: [[gandalf]]". The graph's colour groups
# are set only when it has none. Idempotent.
# Usage: 2.sh <instance folder>
set -eu
rb="${1:?usage: 2.sh <instance folder>}/red-book"
seed="$(cd "$(dirname "$0")/.." && pwd -P)/seed/red-book/.obsidian/graph.json"

# Awk prefix that prints the frontmatter untouched, so the rules after it only see the body.
FM='NR == 1 && /^---$/ {fm = 1; print; next} fm {if (/^---$/) fm = 0; print; next}'

# rewrite <file> <awk program> [awk options]: replace the file only when the program changed it.
rewrite() {
  f=$1 p=$2; shift 2
  awk "$@" "$p" "$f" > "$f.tmp"
  if cmp -s "$f" "$f.tmp"; then rm -f "$f.tmp"; else mv "$f.tmp" "$f"; fi
}

# add_up <file> <target>: an "Up: <target>" line under the note's first heading, unless it has one.
add_up() {
  grep -q '^Up: ' "$1" && return 0
  rewrite "$1" "$FM"' {print} !done && /^# / {print ""; print "Up: " t; done = 1}' -v t="$2"
}

for d in "$rb"/projects/*/; do
  f="$d$(basename "$d").md"
  [ -f "$f" ] || continue
  grep -q '^Up: ' "$f" && continue
  t=$(sed -n 's/^Group: \(\[\[groups\/[^]]*\]\]\).*/\1/p' "$f" | head -n 1)
  if [ -z "$t" ]; then
    g=$(awk 'NR == 1 && /^---$/ {fm = 1; next} fm && /^---$/ {exit}
      fm && /^group:/ {sub(/^group:[ \t]*/, ""); gsub(/["'\'' \t]/, ""); print; exit}' "$f")
    case $g in ''|none) t='[[gandalf]]' ;; *) t="[[groups/$g/$g]]" ;; esac
  fi
  # The old line becomes the Up line, keeping what follows its first " · " (the Rules link).
  rewrite "$f" "$FM"' !done && /^Group: / {i = index($0, " · "); print "Up: " t (i ? substr($0, i) : ""); done = 1; next} {print}' -v t="$t"
  add_up "$f" "$t"
done

for d in "$rb"/groups/*/; do
  f="$d$(basename "$d").md"
  [ -f "$f" ] || continue
  grep -q '^Up: ' "$f" && continue
  rewrite "$f" "$FM"'
    !done && /^Shared by this group.s projects\. Rules: / {
      r=$0; sub(/^.*Rules: /, "", r); print "Up: [[gandalf]] · Rules: " r; print ""; print "Shared by this group'"'"'s projects."; done=1; next}
    {print}'
  add_up "$f" '[[gandalf]]'
done

g="$rb/.obsidian/graph.json"
if [ -f "$g" ] && [ -f "$seed" ] && grep -q '"colorGroups": *\[ *\]' "$g"; then
  # Through the environment, not awk -v, which would turn the JSON's \" escapes into bare quotes.
  CG=$(grep '"colorGroups"' "$seed" | sed 's/^ *"colorGroups": *//; s/, *$//') \
    awk '/"colorGroups": *\[ *\]/ {sub(/\[ *\]/, "@CG@"); i = index($0, "@CG@"); $0 = substr($0, 1, i - 1) ENVIRON["CG"] substr($0, i + 4)} {print}' \
    "$g" > "$g.tmp" && mv "$g.tmp" "$g"
fi
exit 0
