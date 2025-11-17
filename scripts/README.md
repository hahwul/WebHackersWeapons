# Scripts Documentation

This directory contains Ruby scripts for generating, validating, and managing the WebHackersWeapons catalog.

## Overview

The WebHackersWeapons project uses a **data-driven documentation** approach:
1. Tools are defined in YAML files (`weapons/*.yaml`)
2. Scripts transform YAML → Markdown documentation
3. GitHub Actions automate the generation process

---

## Scripts

### erb.rb

**Main documentation generator** that transforms weapon YAML files into comprehensive markdown documentation.

**Purpose:**
- Generate `README.md` with complete tool listing
- Create per-tag categorization (`categorize/tags/*.md`)
- Create per-language categorization (`categorize/langs/*.md`)

**Usage:**
```bash
ruby scripts/erb.rb
```

**Input:**
- `weapons/*.yaml` - Tool definitions
- Embedded ERB templates in the script

**Output:**
- `README.md` - Main catalog with all tools
- `categorize/tags/*.md` - 96 tag-based category pages
- `categorize/langs/*.md` - 19 language-based category pages

**Process:**
1. Load all YAML files from `weapons/`
2. Sort tools by type (Army-Knife, Proxy, Recon, etc.)
3. Generate markdown tables with:
   - Tool name and description
   - GitHub stars (for popularity)
   - Platform badges
   - Language badges
   - Tags
4. Render ERB template to produce final markdown

**Key Functions:**
- `generate_badge(array)` - Creates platform/tool badges
- `generate_tags(array)` - Formats tag lists

**Note:** This script is run automatically by GitHub Actions on every push to `main`.

---

### validate_weapons.rb

**YAML validation script** that checks for missing required fields.

**Purpose:**
- Ensure data quality
- Identify tools missing metadata
- Catch common issues early

**Usage:**
```bash
ruby scripts/validate_weapons.rb
```

**Checks:**
- Missing `type` field
- Missing `lang` field (for GitHub-hosted projects)
- Empty or nil values

**Output:**
```
./weapons/Gf-Patterns.yaml :: none-lang
./weapons/httptoolkit.yaml :: none-lang
./weapons/subs_all.yaml :: none-lang
```

**Exit Code:**
- `0` - Validation passed
- Non-zero - Errors found

---

### export_json.rb

**JSON export utility** that converts the weapon catalog to machine-readable JSON format.

**Purpose:**
- Enable programmatic access to catalog
- Provide data for MCP server
- Support automation and integrations

**Usage:**
```bash
ruby scripts/export_json.rb
```

**Output Files:**

**weapons.json** - Complete tool catalog
```json
{
  "version": "1.0",
  "generated_at": "2025-11-17T12:34:56Z",
  "total_tools": 423,
  "tools": [
    {
      "name": "nuclei",
      "description": "Fast vulnerability scanner",
      "url": "https://github.com/projectdiscovery/nuclei",
      "category": "tool",
      "type": "Scanner",
      "platform": ["linux", "macos", "windows"],
      "lang": "Go",
      "tags": ["vulnerability-scanner"],
      "_meta": {
        "filename": "nuclei.yaml",
        "last_modified": "2025-11-17T10:00:00Z",
        "github_repo": "projectdiscovery/nuclei"
      }
    }
  ]
}
```

**weapons_stats.json** - Statistics and metrics
```json
{
  "generated_at": "2025-11-17T12:34:56Z",
  "total_tools": 423,
  "by_type": {
    "Recon": 125,
    "Scanner": 78,
    "Fuzzer": 42
  },
  "by_language": {
    "Go": 156,
    "Python": 98
  },
  "platforms": {
    "linux": 380,
    "macos": 350,
    "windows": 320
  },
  "tags": {
    "xss": 15,
    "subdomains": 23
  },
  "completeness": {
    "with_tags": 280,
    "without_tags": 143,
    "with_lang": 400,
    "without_lang": 23
  }
}
```

---

### detect_duplicates.rb

**Duplicate detection tool** that finds tools with identical URLs or names.

**Purpose:**
- Maintain data integrity
- Prevent duplicate entries
- Identify merge candidates

**Usage:**
```bash
ruby scripts/detect_duplicates.rb
```

**Checks:**
- Duplicate URLs (case-insensitive, normalized)
- Duplicate names (case-insensitive)

**Output:**
```
❌ DUPLICATE URL: https://github.com/projectdiscovery/subfinder
   File 1: ./weapons/subfinder.yaml
   File 2: ./weapons/subfinder-v2.yaml

============================================================
Duplicate Detection Summary
============================================================
Total files scanned: 423
Unique URLs: 421
Unique names: 422
Duplicates found: 2

⚠️  2 duplicate(s) detected!
```

**Exit Code:**
- `0` - No duplicates found
- `1` - Duplicates detected

---

## Legacy/Archived Scripts

### for_migration/

Contains historical migration scripts used to convert old JSON format to current YAML format.

**Scripts:**
- `migration.rb` - JSON to YAML converter
- `apply_platform.rb` - Platform field migration
- `fetch_lang.rb` - Language field fetcher

**Status:** These scripts are no longer actively used and are kept for historical reference.

---

## Development Workflow

### Adding a New Tool

1. Create `weapons/tool-name.yaml`:
```yaml
---
name: MyTool
description: Does security testing
url: https://github.com/user/mytool
category: tool
type: Scanner
platform: [linux, macos, windows]
lang: Go
tags: [vulnerability-scanner, web-security]
```

2. Validate:
```bash
ruby scripts/validate_weapons.rb
```

3. Check for duplicates:
```bash
ruby scripts/detect_duplicates.rb
```

4. Generate documentation:
```bash
ruby scripts/erb.rb
```

5. Verify output:
```bash
grep "MyTool" README.md
```

### Testing Changes Locally

```bash
# 1. Make changes to YAML files
vim weapons/mytool.yaml

# 2. Validate
ruby scripts/validate_weapons.rb

# 3. Generate docs
ruby scripts/erb.rb

# 4. Check output
git diff README.md

# 5. Export JSON (optional)
ruby scripts/export_json.rb
```

### CI/CD Integration

The GitHub Actions workflow (`.github/workflows/cd.yml`) automatically:
1. Runs `erb.rb` on every push to main
2. Commits generated files
3. Updates contributor SVG

**No manual README editing needed!**

---

## Requirements

### Ruby Version
- **Minimum:** Ruby 3.0
- **Recommended:** Ruby 3.3+

### Dependencies
All scripts use Ruby stdlib only - no gems required!

**Built-in libraries used:**
- `yaml` - YAML parsing
- `erb` - Template rendering
- `json` - JSON export
- `time` - Timestamps

### Installation

```bash
# Check Ruby version
ruby --version

# No gem installation needed!
# All dependencies are built-in
```

---

## Troubleshooting

### "YAML.load is unsafe" Warning

**Fixed!** All scripts now use `YAML.safe_load` instead of `YAML.load`.

### Validation Script Crashes

**Fixed!** The script now properly handles nil values and skips directories.

### Files with Spaces

**Fixed!** All weapon files now use underscores instead of spaces.

### Permission Denied

Make scripts executable:
```bash
chmod +x scripts/*.rb
```

---

## Best Practices

### For Contributors

1. **Always validate** before committing:
   ```bash
   ruby scripts/validate_weapons.rb
   ```

2. **Check for duplicates:**
   ```bash
   ruby scripts/detect_duplicates.rb
   ```

3. **Test generation locally:**
   ```bash
   ruby scripts/erb.rb
   ```

4. **Don't edit generated files** - Edit YAML source instead

### For Maintainers

1. **Review PRs carefully** - Ensure YAML is valid
2. **Run all scripts** before merging
3. **Keep scripts updated** - Follow Ruby best practices
4. **Monitor CI/CD** - Ensure generation succeeds

---

## Future Enhancements

Planned improvements:
- [ ] JSON Schema validation
- [ ] Comprehensive test suite
- [ ] GitHub API integration for star counts
- [ ] Automatic language detection
- [ ] Tag suggestion tool
- [ ] Performance optimization

See [IMPROVEMENT_PLAN.md](../IMPROVEMENT_PLAN.md) for details.

---

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines.

---

## License

Same as main project - see [LICENSE](../LICENSE)
