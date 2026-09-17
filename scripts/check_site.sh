#!/usr/bin/env bash
# Verifies that the site is still the single scrolling home page it is meant to be.
#
# Checks the sources (only a home page and a 404 page, no navbar entries, no intro
# prose on the home page) and the build output (sidebar with photo, name, role and
# colored social links; Publications and Projects sections; a CV section only when
# there is CV data; no navbar menu; no separate publications/projects/CV pages).
# Run `bundle exec jekyll build` first: the output checks read _site/.

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

body() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { inside = 0; after = 1; next } after' "$1"
}

for file in "$pages_dir"/*.md; do
  if front_matter "$file" | grep -qE '^nav:[[:space:]]*true'; then
    fail "$(basename "$file") sets nav: true, but the site has no navbar menu"
  fi
done

# The home page body is sections only: every non-blank line is HTML or Liquid.
# A line of plain prose would be an intro paragraph creeping back in.
prose="$(body "$pages_dir/about.md" | grep -vE '^[[:space:]]*$' | grep -vE '^[[:space:]]*(<|\{%)' || true)"
if [ -n "$prose" ]; then
  fail "about.md carries prose outside the sections: $(printf '%s' "$prose" | head -1)"
fi

# --- build output -----------------------------------------------------------

if [ ! -f "$index" ]; then
  fail "_site/index.html is missing; run 'bundle exec jekyll build' first"
  exit "$status"
fi

sidebar="$(sed -n '/<aside class="home-side">/,/<\/aside>/p' "$index")"
if [ -z "$sidebar" ]; then
  fail "the home page has no <aside class=\"home-side\"> sidebar"
fi
printf '%s' "$sidebar" | grep -q '<h1 class="home-name">Sungsoo Lee</h1>' || fail "the sidebar has no name heading"
printf '%s' "$sidebar" | grep -q 'class="home-photo"' || fail "the sidebar has no profile photo"
printf '%s' "$sidebar" | grep -q 'Ph.D. Student' || fail "the sidebar has no role line"
printf '%s' "$sidebar" | grep -q 'Department of Data Science' || fail "the sidebar has no affiliation line"
for icon in home-social-email home-social-github home-social-linkedin home-social-scholar; do
  printf '%s' "$sidebar" | grep -q "class=\"$icon\"" || fail "the sidebar has no $icon link"
done
printf '%s' "$sidebar" | grep -q 'scholar.google.com/citations?user=sy0--vAAAAAJ' || fail "the Google Scholar link points elsewhere"
printf '%s' "$sidebar" | grep -q 'class="home-interests"' || fail "the sidebar has no research-interest line"
printf '%s' "$sidebar" | grep -q 'class="home-email" href="mailto:sungsoo207@ds.seoultech.ac.kr">sungsoo207@ds.seoultech.ac.kr</a>' || fail "the sidebar has no plain-text email address"
counts=$(grep -o 'class="home-count">[0-9]*</span>' "$index" | wc -l | tr -d ' ')
[ "$counts" -ge 2 ] || fail "expected a count next to each section heading, found $counts"
grep -q 'Last updated: ' "$index" || fail "the footer has no last-updated stamp (last_updated in _config.yml)"

for section in publications projects; do
  grep -q "<section id=\"$section\">" "$index" || fail "no <section id=\"$section\"> on the home page"
done

# The CV section is data-driven: scripts/notion_sync.py only writes `sections` into
# _data/cv.yml when the Notion CV Entries database has public rows, and about.md
# hides the section when there are none.
if grep -qE '^  sections:' "$repo_root/_data/cv.yml"; then
  grep -q '<section id="cv">' "$index" || fail "_data/cv.yml has sections but the home page has no <section id=\"cv\">"
elif grep -q '<section id="cv">' "$index"; then
  fail "_data/cv.yml has no sections, so the CV section should be hidden"
fi

# Same for patents: scripts/notion_sync.py writes _data/patents.yml as a list, and
# about.md renders the section only when that list is non-empty.
if grep -qE '^- ' "$repo_root/_data/patents.yml"; then
  grep -q '<section id="patents">' "$index" || fail "_data/patents.yml has entries but the home page has no <section id=\"patents\">"
elif grep -q '<section id="patents">' "$index"; then
  fail "_data/patents.yml is empty, so the patents section should be hidden"
fi

grep -q "LG Electronics" "$index" || fail "the project list is missing from the home page"
grep -q 'class="project-status' "$index" || fail "the project rows carry no status pill"
grep -q 'class="bibliography"' "$index" || fail "the bibliography is missing from the home page"
grep -q 'class="pub-row"' "$index" || fail "the publication rows are missing from the home page"
grep -q 'class="pub-type"' "$index" || fail "the publication rows carry no type pill"
if grep -q '<h2 class="bibliography">' "$index"; then
  fail "the bibliography still renders year headings; scholar.group_by should be none"
fi

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
  echo "check_site: sidebar home page with publications, projects and CV, no navbar menu"
fi

exit "$status"
