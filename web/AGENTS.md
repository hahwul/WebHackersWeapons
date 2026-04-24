# AGENTS.md - AI Agent Instructions for Hwaro Site

This document provides instructions for AI agents working on this Hwaro-generated website.

## Project Overview

This is a static website built with [Hwaro](https://github.com/hahwul/hwaro), a fast and lightweight static site generator written in Crystal.

## Essential Commands

| Command | Description |
|---------|-------------|
| `hwaro build` | Build the site to `public/` directory |
| `hwaro serve` | Start development server with live reload |
| `hwaro new <path>` | Create new content from archetype |
| `hwaro deploy` | Deploy the site (requires configuration) |
| `hwaro build --drafts` | Include draft content |
| `hwaro serve -p 8080` | Serve on custom port (default: 3000) |
| `hwaro build --base-url "https://example.com"` | Set base URL for production |

## Directory Structure

```
.
├── config.toml          # Site configuration
├── content/             # Markdown content files
│   ├── _index.md        # Homepage content
│   └── blog/            # Blog section
│       ├── _index.md    # Section listing page
│       └── *.md         # Individual pages
├── templates/           # Jinja2 templates (Crinja)
│   ├── base.html        # Base layout (optional)
│   ├── page.html        # Page template
│   ├── section.html     # Section listing template
│   └── shortcodes/      # Shortcode templates
├── static/              # Static assets (copied as-is)
└── archetypes/          # Content templates for `hwaro new`
```

## Notes for AI Agents

1. **Front matter is TOML** (`+++`), not YAML (`---`).
2. **Rendered content** is `{{ content | safe }}`, not `{{ page.content }}`.
3. **Custom metadata** is `page.extra.field`, not `page.params.field`.
4. **Always preview** with `hwaro serve` before committing.
5. **Validate TOML syntax** in config.toml and front matter after edits.
6. **Use `{{ base_url }}` prefix** for URLs in templates.
7. **Escape user content** with `{{ value | escape }}` in templates.

## Full Reference

For detailed documentation on content, templates, configuration, and more:

- [Hwaro Documentation](https://hwaro.hahwul.com)
- [Configuration Guide](https://hwaro.hahwul.com/start/config/)
- [Full LLM Reference](https://hwaro.hahwul.com/llms-full.txt) — comprehensive reference optimized for AI agents

To generate the full embedded AGENTS.md locally, run:
```
hwaro tool agents-md --local --write
```

## Site-Specific Instructions

This site renders the WebHackersWeapons catalog. `data/weapons.json`, `content/weapons/*.md`, and `static/api/**` are **generated** at build time by `scripts/generate.cr` (Crystal) — a pre-build hook declared in `config.toml` (`[build] hooks.pre = ["crystal run scripts/generate.cr"]`). Source of truth is `../weapons/*.toml` at the repo root. Do not edit the generated files directly; re-run a build (`../hwaro/bin/hwaro build`) after touching a TOML.

The generator depends on the `toml` shard (declared in `web/shard.yml`). Run `shards install` once from `web/` before the first build; `shard.lock` pins versions.

## Validation

`scripts/validate.cr` checks every file in `../weapons/` against the canonical schema. Run from `web/`:

```
crystal run scripts/validate.cr            # text output
crystal run scripts/validate.cr -- --json  # machine-readable
```

The canonical value sets (`CATEGORIES`, `TYPES`, `PLATFORMS`) plus `slugify` and TOML-escape helpers live in `scripts/schema.cr` and are shared by both `validate.cr` and `generate.cr` to prevent drift. If you need to add a new platform or category, update that one module.

Exits 1 on any error (warnings don't fail). Enforced rules:

- required: `name` (non-empty string), `category` ∈ `{tool, tool-addon, browser-addon}`, at least one of `url` or `source`
- `url`: array of strings, each starting with `http://` or `https://`
- `source`: optional single string, source code repo URL (http/https)
- optional (validated if present): `type` ∈ `{Utils, Recon, Scanner, Fuzzer, Exploit, Proxy, Army-Knife, Env}`, `platform` ⊂ `{linux, macos, windows, firefox, chrome, safari, burpsuite, zap, caido}`, `tags` is an array of strings
- derived: slug (`slugify(name)`) is unique across all files

`lang` missing/empty is a warning only (many browser-extensions/services have no language). The `.github/workflows/validate.yml` workflow runs the validator on every PR and push touching `weapons/**`.

## Deploy

Site deploys to `https://weapons.hahwul.com` via GitHub Pages. The flow is in `.github/workflows/deploy.yml`:

1. Runner installs Crystal, runs `shards install`, then the validator and generator.
2. `hahwul/hwaro@main` action runs `hwaro build -e production` inside the Debian Docker image.

The Docker image only carries the `hwaro` binary — no Crystal toolchain — so the pre-build hook in `config.toml` would fail there. `config.production.toml` overrides `[build] hooks.pre = []` and sets `base_url = "https://weapons.hahwul.com"`. Pre-generated markdown / JSON / data files from the runner are reused by the in-Docker build.

The canonical hostname is declared in `static/CNAME` so GitHub Pages serves `weapons.hahwul.com` after the first deploy to `gh-pages`. Repo settings must point Pages at the `gh-pages` branch; the DNS record (`weapons` CNAME → `hahwul.github.io`) lives outside this repo.

Templates:
- `home.html` — homepage card grid, iterates `site.data.weapons` (array loaded from `data/weapons.json`).
- `weapons.html` — full list with filter dropdowns, same data source.
- `weapon.html` — per-tool detail page. Reads `page.extra.*` (name, url, type, lang, category, platform, api, raw_tags). Note: TOML `[extra]` subtables do NOT work in hwaro 0.12.1 — custom keys must live at the top level of front matter and hwaro auto-classifies unknown keys into `page.extra`.
- `taxonomy.html` / `taxonomy_term.html` — tag index and per-tag card grids using `site.taxonomies[taxonomy_name].items`.

`data/weapons/` must not be a symlink — Crystal's `Dir.glob` does not follow symlinks, so `site.data.weapons` stays empty. The generator writes a plain `data/weapons.json` instead.

## Collections

Curated pages under `content/collections/` group existing weapons into workflow-specific bundles. They use the `weapons` shortcode in `templates/shortcodes/weapons.html`:

```markdown
{{ weapons("burpsuite", "zap", "caido") }}
```

Each arg is a slug (lowercase dash-joined weapon name = the URL segment under `/weapons/<slug>/`). Up to 16 positional slots per call; split across multiple shortcode calls for longer lists. Ordering is preserved. Unknown slugs are silently skipped.

Why positional args and not a single array? Hwaro's shortcode parser (`SHORTCODE_ARGS_REGEX`) only accepts scalar String kwargs, and Crinja has no `split` filter — so an array-kwarg or comma-joined string would lose ordering. Positional args arrive as `_0, _1, _2 ...` which keeps intent and order intact.

Note on HTML validity: shortcodes expand to a placeholder **before** Markdown runs, and Markdown wraps any placeholder that sits on its own line in `<p>…</p>`. The resulting `<p><div class="card-grid">…</div></p>` is technically invalid HTML but renders correctly in every browser (the `<div>` implicitly closes the `<p>`). No workaround inside hwaro 0.12.1 without modifying the upstream shortcode processor.