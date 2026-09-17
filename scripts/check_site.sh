#!/usr/bin/env bash
# Verifies that the site is still the single scrolling home page it is meant to be.
#
# Checks the sources (only a home page and a 404 page, no navbar entries) and the
# build output (sidebar with photo, name, role and colored social links; About,
# Publications and Projects sections; Education, Honors and Patents sections only
# when there is data for them; no navbar menu; no separate publications/projects/CV
# pages).
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

for file in "$pages_dir"/*.md; do
  if front_matter "$file" | grep -qE '^nav:[[:space:]]*true'; then
    fail "$(basename "$file") sets nav: true, but the site has no navbar menu"
  fi
done

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
if grep -q 'class="home-email"' "$index"; then
  fail "the plain-text email address is back under the sidebar icons; the mail icon is enough"
fi
counts=$(grep -o 'class="home-count">[0-9]*</span>' "$index" | wc -l | tr -d ' ')
[ "$counts" -ge 2 ] || fail "expected a count next to each section heading, found $counts"
grep -q 'Last updated: ' "$index" || fail "the footer has no last-updated stamp (last_updated in _config.yml)"

for section in about publications projects; do
  grep -q "<section id=\"$section\">" "$index" || fail "no <section id=\"$section\"> on the home page"
done

about="$(sed -n '/<section id="about">/,/<\/section>/p' "$index")"
printf '%s' "$about" | grep -q '<p' || fail "the about section carries no intro paragraph"

# The intro comes first: it is what a visitor should read before the lists.
offset_of() {
  grep -b -o "$1" "$index" | head -1 | cut -d: -f1
}
about_at="$(offset_of '<section id="about">' || true)"
publications_at="$(offset_of '<section id="publications">' || true)"
if [ -n "$about_at" ] && [ -n "$publications_at" ] && [ "$about_at" -gt "$publications_at" ]; then
  fail "the about section comes after the publications section"
fi

# Education, honors and patents are data-driven: scripts/notion_sync.py writes each
# _data file as a list, and about.md renders the section only when its list is
# non-empty.
for section in education honors patents; do
  data="$repo_root/_data/$section.yml"
  if grep -qE '^- ' "$data"; then
    grep -q "<section id=\"$section\">" "$index" || fail "_data/$section.yml has entries but the home page has no <section id=\"$section\">"
  elif grep -q "<section id=\"$section\">" "$index"; then
    fail "_data/$section.yml is empty, so the $section section should be hidden"
  fi
done

if grep -q '<section id="education">' "$index"; then
  grep -q 'class="pub-when"' "$index" || fail "the education rows carry no period"
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
  echo "check_site: sidebar home page with about, publications and projects, no navbar menu"
fi

exit "$status"
