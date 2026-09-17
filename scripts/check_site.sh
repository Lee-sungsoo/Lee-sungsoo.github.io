#!/usr/bin/env bash
# Verifies that the navigation bar lists exactly the five intended pages.
#
# al-folio renders the About page (the one with `permalink: /`) as a hard-coded
# first navbar entry, then appends every page with `nav: true`. So the pages
# actually visible in the navbar are About plus the `nav: true` pages, and the
# About page must NOT also set `nav: true` or it would be listed twice.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pages_dir="$repo_root/_pages"
expected="about cv projects publications repositories"

front_matter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside' "$1"
}

field() {
  printf '%s\n' "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -1 | tr -d "\"'" | tr -d '\r'
}

status=0
nav_names=()

for file in "$pages_dir"/*.md; do
  matter="$(front_matter "$file")"
  permalink="$(field "$matter" permalink)"
  nav="$(field "$matter" nav)"

  name="$(printf '%s' "$permalink" | sed 's#^/##; s#/$##')"
  [ -z "$name" ] && name="about"

  if [ "$permalink" = "/" ]; then
    if [ "$nav" = "true" ]; then
      echo "FAIL $(basename "$file"): sets nav: true, but About is already hard-coded in the navbar" >&2
      status=1
    fi
    nav_names+=("$name")
  elif [ "$nav" = "true" ]; then
    nav_names+=("$name")
  fi
done

actual="$(printf '%s\n' "${nav_names[@]}" | sort | tr '\n' ' ' | sed 's/ *$//')"
wanted="$(printf '%s\n' $expected | sort | tr '\n' ' ' | sed 's/ *$//')"

if [ "$actual" != "$wanted" ]; then
  echo "FAIL navbar pages differ" >&2
  echo "  expected: $wanted" >&2
  echo "  actual:   $actual" >&2
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "check_site: navbar lists exactly 5 pages: $actual"
fi

exit "$status"
