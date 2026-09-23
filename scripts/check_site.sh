#!/usr/bin/env bash
# Verifies that the site is still the four-tab sidebar site it is meant to be.
#
# Checks the sources (exactly four `nav: true` pages) and the build output: every
# tab carries the one shared sidebar (photo, name, role, affiliation, interests,
# colored social links) and the same four-link navbar with the current tab
# marked; Home holds About, Education and Honors; Research holds the
# bibliography, the presentations and the patents, in that order; Projects holds
# the project list; CV embeds assets/pdf/cv.pdf when the file is there and says
# so when it is not. Education, honors and patents render only when _data has
# rows for them.
# Run `bundle exec jekyll build` first: the output checks read _site/.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pages_dir="$repo_root/_pages"
site_dir="$repo_root/_site"
index="$site_dir/index.html"
status=0

# tab id : url : navbar label, in navbar order.
tabs="home:/:Home research:/research/:Research projects:/projects/:Projects cv:/cv/:CV"

fail() {
  echo "FAIL $1" >&2
  status=1
}

built_page() {
  if [ "$1" = "home" ]; then
    echo "$site_dir/index.html"
  else
    echo "$site_dir/$1/index.html"
  fi
}

# --- sources ----------------------------------------------------------------

front_matter() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next } inside && $0 == "---" { exit } inside' "$1"
}

nav_pages=""
for file in "$pages_dir"/*.md; do
  if front_matter "$file" | grep -qE '^nav:[[:space:]]*true'; then
    nav_pages="$nav_pages $(basename "$file")"
  fi
done
nav_pages="$(printf '%s\n' $nav_pages | sort | tr '\n' ' ' | sed 's/ *$//')"
if [ "$nav_pages" != "about.md cv.md projects.md research.md" ]; then
  fail "the nav: true pages are '$nav_pages', expected 'about.md cv.md projects.md research.md'"
fi

# --- every tab: the shared shell --------------------------------------------

for tab in $tabs; do
  id="${tab%%:*}"
  rest="${tab#*:}"
  url="${rest%%:*}"
  page="$(built_page "$id")"

  if [ ! -f "$page" ]; then
    fail "${page#$repo_root/} is missing; run 'bundle exec jekyll build' first"
    continue
  fi

  sidebar="$(sed -n '/<aside class="home-side">/,/<\/aside>/p' "$page")"
  if [ -z "$sidebar" ]; then
    fail "the $id page has no <aside class=\"home-side\"> sidebar"
  fi
  printf '%s' "$sidebar" | grep -q '<h1 class="home-name">Sungsoo Lee</h1>' || fail "the $id sidebar has no name heading"
  printf '%s' "$sidebar" | grep -q 'class="home-photo"' || fail "the $id sidebar has no profile photo"
  printf '%s' "$sidebar" | grep -q 'Ph.D. Student' || fail "the $id sidebar has no role line"
  printf '%s' "$sidebar" | grep -q 'Department of Data Science' || fail "the $id sidebar has no affiliation line"
  for icon in home-social-email home-social-github home-social-linkedin home-social-scholar; do
    printf '%s' "$sidebar" | grep -q "class=\"$icon\"" || fail "the $id sidebar has no $icon link"
  done
  printf '%s' "$sidebar" | grep -q 'scholar.google.com/citations?user=sy0--vAAAAAJ' || fail "the $id Google Scholar link points elsewhere"
  printf '%s' "$sidebar" | grep -q 'class="home-interests"' || fail "the $id sidebar has no research-interest line"
  if grep -q 'class="home-email"' "$page"; then
    fail "the plain-text email address is back under the $id sidebar icons; the mail icon is enough"
  fi

  # The navbar lists all four tabs, and marks the one being rendered. No
  # hamburger: the theme hides .collapse from inside a cascade layer, so the
  # links have to stay visible at every width.
  nav="$(sed -n '/<nav id="navbar"/,/<\/nav>/p' "$page")"
  for other in $tabs; do
    other_rest="${other#*:}"
    other_url="${other_rest%%:*}"
    other_label="${other_rest#*:}"
    printf '%s' "$nav" | grep -q "href=\"$other_url\">$other_label" || fail "the $id navbar has no $other_label link"
  done
  items=$(printf '%s' "$nav" | grep -o '<li class="nav-item' | wc -l | tr -d ' ')
  [ "$items" -eq 4 ] || fail "the $id navbar carries $items page links, expected exactly 4"
  actives=$(printf '%s' "$nav" | grep -c '<li class="nav-item active">' || true)
  if [ "$actives" -ne 1 ]; then
    fail "the $id navbar marks $actives links active, expected exactly 1"
  elif ! printf '%s' "$nav" | grep -A 2 '<li class="nav-item active">' | grep -q "href=\"$url\""; then
    fail "the $id navbar marks some other tab active"
  fi
  if printf '%s' "$nav" | grep -q 'navbar-toggler'; then
    fail "the $id navbar is back to a hamburger, which the theme's CSS keeps collapsed"
  fi

  grep -q 'Last updated: ' "$page" || fail "the $id footer has no last-updated stamp (last_updated in _config.yml)"
done

if [ ! -f "$index" ]; then
  exit "$status"
fi

# --- home: about, education, honors -----------------------------------------

grep -q '<section id="about">' "$index" || fail "no <section id=\"about\"> on the home page"

about="$(sed -n '/<section id="about">/,/<\/section>/p' "$index")"
printf '%s' "$about" | grep -q '<p' || fail "the about section carries no intro paragraph"

# The intro comes first: it is what a visitor should read before the lists.
offset_of() {
  grep -b -o "$2" "$1" | head -1 | cut -d: -f1
}
about_at="$(offset_of "$index" '<section id="about">' || true)"
education_at="$(offset_of "$index" '<section id="education">' || true)"
if [ -n "$about_at" ] && [ -n "$education_at" ] && [ "$about_at" -gt "$education_at" ]; then
  fail "the about section comes after the education section"
fi

# Education, honors and patents are data-driven: scripts/notion_sync.py writes each
# _data file as a list, and the page renders the section only when its list is
# non-empty. Education and honors belong to the home page, patents to publications.
check_data_section() {
  section="$1"
  page="$2"
  data="$repo_root/_data/$section.yml"
  if grep -qE '^- ' "$data"; then
    grep -q "<section id=\"$section\">" "$page" || fail "_data/$section.yml has entries but ${page#$repo_root/} has no <section id=\"$section\">"
  elif grep -q "<section id=\"$section\">" "$page"; then
    fail "_data/$section.yml is empty, so the $section section should be hidden"
  fi
}
check_data_section education "$index"
check_data_section honors "$index"

if grep -q '<section id="education">' "$index"; then
  grep -q 'class="pub-when"' "$index" || fail "the education rows carry no period"
fi

if grep -q '<section id="honors">' "$index"; then
  grep -q '<h2>Honors</h2>' "$index" || fail "the honors heading is not the plain <h2>Honors</h2>"
  if grep -q 'Honors &amp; Awards' "$index"; then
    fail "the honors heading still reads 'Honors & Awards'"
  fi
fi

# The lists that moved out must not also be left behind here: a half-finished
# split renders them twice, once on Home and once on their own tab.
for section in publications patents presentations projects; do
  if grep -q "<section id=\"$section\">" "$index"; then
    fail "the home page still carries <section id=\"$section\">, which belongs on its own tab"
  fi
done

# --- research: bibliography, presentations and patents ---------------------

research="$site_dir/research/index.html"
if [ -f "$research" ]; then
  grep -q 'class="bibliography"' "$research" || fail "the bibliography is missing from the research page"
  grep -q 'class="pub-row"' "$research" || fail "the publication rows are missing from the research page"
  grep -q 'class="pub-type"' "$research" || fail "the publication rows carry no type pill"
  if grep -q '<h2 class="bibliography">' "$research"; then
    fail "the bibliography still renders year headings; scholar.group_by should be none"
  fi
  grep -q '<section id="presentations">' "$research" || fail "no <section id=\"presentations\"> on the research page"
  sed -n '/<section id="presentations">/,/<\/section>/p' "$research" | grep -q 'class="pub-row"' || fail "the presentation rows are missing from the research page"
  check_data_section patents "$research"

  # Publications, then presentations, then patents.
  publications_at="$(offset_of "$research" '<section id="publications">' || true)"
  presentations_at="$(offset_of "$research" '<section id="presentations">' || true)"
  patents_at="$(offset_of "$research" '<section id="patents">' || true)"
  if [ -n "$publications_at" ] && [ -n "$presentations_at" ] && [ "$publications_at" -gt "$presentations_at" ]; then
    fail "the presentations section comes before the publications section"
  fi
  if [ -n "$presentations_at" ] && [ -n "$patents_at" ] && [ "$presentations_at" -gt "$patents_at" ]; then
    fail "the patents section comes before the presentations section"
  fi
fi

# The old Publications and Presentations tabs are folded into Research; their
# pages must not linger in the build.
for old_tab in publications presentations; do
  if [ -e "$site_dir/$old_tab" ]; then
    fail "_site/$old_tab/ still exists; that tab is now part of Research"
  fi
done

# --- projects ---------------------------------------------------------------

projects="$site_dir/projects/index.html"
if [ -f "$projects" ]; then
  grep -q 'LG Electronics' "$projects" || fail "the project list is missing from the projects page"
  grep -q 'class="project-status' "$projects" || fail "the project rows carry no status pill"
fi

# Each list heading keeps its count badge.
for page in "$research" "$projects"; do
  [ -f "$page" ] || continue
  counts=$(grep -o 'class="home-count">[0-9]*</span>' "$page" | wc -l | tr -d ' ')
  [ "$counts" -ge 1 ] || fail "expected a count next to the headings of ${page#$repo_root/}, found none"
done

# --- cv: the PDF when it is there, a note when it is not ---------------------

cv="$site_dir/cv/index.html"
if [ -f "$cv" ]; then
  if [ -f "$repo_root/assets/pdf/cv.pdf" ]; then
    grep -q 'class="cv-embed"' "$cv" || fail "assets/pdf/cv.pdf exists but the cv page does not embed it"
    grep -q 'Download PDF' "$cv" || fail "assets/pdf/cv.pdf exists but the cv page has no download button"
  else
    grep -q 'not posted yet' "$cv" || fail "assets/pdf/cv.pdf is missing, so the cv page should say the CV is not up yet"
    if grep -q 'class="cv-embed"' "$cv"; then
      fail "the cv page embeds a viewer, but there is no assets/pdf/cv.pdf to show"
    fi
  fi
fi

if [ "$status" -eq 0 ]; then
  echo "check_site: four tabs (home, research, projects, cv), one sidebar and one navbar on each"
fi

exit "$status"
