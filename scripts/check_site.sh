#!/usr/bin/env bash
# Verifies that the site is still the single scrolling page it is meant to be.
#
# Checks the sources (only an About page and a 404 page, no navbar entries, photo
# on the left) and the build output (the three sections are on the home page, the
# navbar carries no menu links, and no separate publications/projects/CV pages were
# written). Run `bundle exec jekyll build` first: the output checks read _site/.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pages_dir="$repo_root/_pages"
index="$repo_root/_site/index.html"
status=0

fail() {
  echo "FAIL $1" >&2
  status=1
}

# --- sources ----------------------------------------------------------------

pages="$(cd "$pages_dir" && printf '%s\n' *.md | sort | tr '\n' ' ' | sed 's/ *$//')"
if [ "$pages" != "404.md about.md" ]; then
  fail "_pages holds '$pages', expected '404.md about.md'"
fi

front_matter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside' "$1"
}

for file in "$pages_dir"/*.md; do
  if front_matter "$file" | grep -qE '^nav:[[:space:]]*true'; then
    fail "$(basename "$file") sets nav: true, but the site has no navbar menu"
  fi
done

if ! front_matter "$pages_dir/about.md" | grep -qE '^[[:space:]]+align:[[:space:]]*left'; then
  fail "about.md does not set profile.align: left"
fi

# --- build output -----------------------------------------------------------

if [ ! -f "$index" ]; then
  fail "_site/index.html is missing; run 'bundle exec jekyll build' first"
  exit "$status"
fi

for section in publications projects; do
  grep -q "<h2 id=\"$section\">" "$index" || fail "no <h2 id=\"$section\"> heading on the home page"
done

# The CV section is data-driven: scripts/notion_sync.py only writes `sections` into
# _data/cv.yml when the Notion CV Entries database has public rows, and about.md
# hides the heading when there are none.
if grep -qE '^  sections:' "$repo_root/_data/cv.yml"; then
  grep -q '<h2 id="cv">' "$index" || fail "_data/cv.yml has sections but the home page has no <h2 id=\"cv\"> heading"
elif grep -q '<h2 id="cv">' "$index"; then
  fail "_data/cv.yml has no sections, so the CV heading should be hidden"
fi

grep -q "LG Electronics" "$index" || fail "the project list is missing from the home page"
grep -q 'class="bibliography"' "$index" || fail "the bibliography is missing from the home page"

# Nothing but the theme toggle is left up there: no About entry, no `nav: true`
# pages, and `search_enabled: false`, so no element carries the nav-link class.
nav="$(sed -n '/<nav id="navbar"/,/<\/nav>/p' "$index")"
if printf '%s' "$nav" | grep -q 'nav-link'; then
  fail "the navbar still carries nav-link elements"
fi

for page in publications projects cv repositories; do
  if [ -e "$repo_root/_site/$page" ]; then
    fail "_site/$page exists, but everything lives on the single page now"
  fi
done

if [ "$status" -eq 0 ]; then
  echo "check_site: single page with publications, projects and CV, no navbar menu"
fi

exit "$status"
