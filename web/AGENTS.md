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

This site renders the WebHackersWeapons catalog. `data/weapons.json`, `content/weapons/*.md`, and `static/api/**` are **generated** at build time by `scripts/generate.rb` — a pre-build hook declared in `config.toml` (`[build] hooks.pre`). Source of truth is `../weapons/*.yaml` at the repo root. Do not edit the generated files directly; re-run a build (`../hwaro/bin/hwaro build`) after touching a YAML.

Templates:
- `home.html` — homepage card grid, iterates `site.data.weapons` (array loaded from `data/weapons.json`).
- `weapons.html` — full list with filter dropdowns, same data source.
- `weapon.html` — per-tool detail page. Reads `page.extra.*` (name, url, type, lang, category, platform, api, raw_tags). Note: TOML `[extra]` subtables do NOT work in hwaro 0.12.1 — custom keys must live at the top level of front matter and hwaro auto-classifies unknown keys into `page.extra`.
- `taxonomy.html` / `taxonomy_term.html` — tag index and per-tag card grids using `site.taxonomies[taxonomy_name].items`.

`data/weapons/` must not be a symlink — Crystal's `Dir.glob` does not follow symlinks, so `site.data.weapons` stays empty. The generator writes a plain `data/weapons.json` instead.