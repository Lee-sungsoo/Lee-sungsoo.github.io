# lee-sungsoo.github.io

Personal academic site of Sungsoo Lee: <https://lee-sungsoo.github.io>.
Built with [al-folio](https://github.com/alshedivat/al-folio) (Jekyll). Everything
lives on one scrolling page (`_pages/about.md`): intro, publications, projects, CV.

## Content comes from Notion

Publications, projects, and the CV are **generated**, not hand-edited. The source of
truth is Notion (Research, Projects, CV Entries, Patents databases); only rows with
the `공개` checkbox ticked are published.

Generated files, do not edit by hand:

- `_bibliography/papers.bib`
- `_projects/*.md`
- `_data/education.yml`
- `_data/honors.yml`
- `_data/patents.yml`

## Sync

```bash
uv run --script scripts/notion_sync.py          # regenerate from Notion
uv run --script scripts/notion_sync.py --check  # regenerate, then validate the output
uv run --script scripts/notion_sync.py --all    # include non-public rows (preview only)
```

The token is read from `$NOTION_TOKEN`, falling back to the macOS keychain item
`notion-api-token`. `.github/workflows/notion-sync.yml` runs the sync daily at
06:00 KST and triggers a deploy when anything changed.

## Local build

```bash
bundle install
bundle exec jekyll build      # output in _site/
bundle exec jekyll serve      # http://localhost:4000
bash scripts/check_site.sh    # single page, no navbar menu (reads _site/, so build first)
```
