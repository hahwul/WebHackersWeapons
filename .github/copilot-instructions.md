# WebHackersWeapons Repository
WebHackersWeapons is a curated collection of web security tools and utilities. It contains 409+ security tools categorized by type (Army-knife, Proxy, Recon, Fuzzer, Scanner, Exploit, Utils, etc.), platform, language, and tags.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively
- **NEVER CANCEL**: All build operations complete in under 2 seconds. No timeouts needed.
- Bootstrap and validate the repository:
  - Ruby 3.x with erb and yaml gems (pre-installed in GitHub Actions)
  - `ruby ./scripts/erb.rb` -- builds README.md and categorize/* files. Takes ~0.3 seconds.
  - `ruby ./scripts/validate_weapons.rb` -- validates weapon definitions. Takes ~0.1 seconds.
  - `yamllint weapons/*.yaml` -- validates YAML syntax. Takes ~1 second.
- The build process is extremely fast - **ALL commands complete in under 2 seconds**.

## Repository Structure
Key directories and files:
- `weapons/*.yaml` -- Individual weapon definitions (409 files, 3800+ lines total)
- `scripts/erb.rb` -- Main build script that generates all documentation
- `scripts/validate_weapons.rb` -- Validation script for weapon definitions
- `README.md` -- Auto-generated main documentation (DO NOT edit manually)
- `categorize/langs/*.md` -- Auto-generated language-specific lists (19 languages)
- `categorize/tags/*.md` -- Auto-generated tag-specific lists (73 tags)
- `.github/workflows/` -- CI/CD automation
- `.yamllint.yml` -- YAML linting configuration

## Build Process
**CRITICAL**: The `README.md` and `categorize/*` files are AUTO-GENERATED. Never edit them manually.

Build and validate workflow:
1. `ruby ./scripts/erb.rb` -- Generates README.md and all categorize/* files
2. `ruby ./scripts/validate_weapons.rb` -- Shows validation warnings for incomplete entries
3. `yamllint weapons/*.yaml` -- Validates YAML syntax and formatting

All operations complete in under 2 seconds total.

## Adding New Weapons
Create a new file in `weapons/<toolname>.yaml` with this exact format:

```yaml
---
name: Tool Name
description: Tool description
url: https://github.com/owner/repo  # Tool URL
category: tool  # tool | tool-addon | browser-addon | bookmarklet
type: Scanner   # Army-knife | Proxy | Recon | Fuzzer | Scanner | Exploit | Env | Utils | Etc
platform: [linux, macos, windows]  # linux | macos | windows | firefox | safari | chrome | zap | burpsuite
lang: Python    # Language: Go | Python | Ruby | JavaScript | etc.
tags: [xss, sqli]  # Vulnerability/feature tags
```

**CRITICAL YAML Requirements**:
- File MUST end with a newline character (yamllint requirement)
- Use exact platform values: `linux`, `macos`, `windows`, `firefox`, `safari`, `chrome`, `zap`, `burpsuite`
- Use exact type values from the list above
- Use exact category values from the list above

## Validation Workflow
**ALWAYS run these steps after making changes:**

1. **YAML Validation**: `yamllint weapons/*.yaml`
2. **Build Validation**: `ruby ./scripts/erb.rb`
3. **Content Validation**: `ruby ./scripts/validate_weapons.rb`
4. **Manual Check**: Verify your tool appears in the generated README.md

## CI/CD Process
- **Pull Requests**: Automatically run YAML linting via `.github/workflows/yaml-lint.yml`
- **Main Branch**: Automatically regenerates README.md and categorize/* files via `.github/workflows/cd.yml`
- The CI uses Ruby 3.0 and installs `erb` and `yaml` gems

## Common Validation Issues
- **"no new line character at the end of file"**: Add a blank line at the end of YAML files
- **"none-lang" warnings**: Add appropriate `lang:` field for GitHub-hosted tools  
- **"undefined method length"**: Ensure `tags:` field exists and is an array
- **"Is a directory" errors**: Normal warnings from validation script reading directory entries

## Error Examples
```bash
# Missing newline error:
::error file=weapons/tool.yaml,line=9,col=13::9:13 [new-line-at-end-of-file] no new line character at the end of file

# Fix by adding blank line at end of file:
echo "" >> weapons/tool.yaml
```

## Manual Validation Scenarios
After adding a new weapon, verify:
1. **YAML Syntax**: `yamllint weapons/yourfile.yaml` returns no errors
2. **Build Success**: `ruby ./scripts/erb.rb` completes without errors
3. **README Generation**: Your tool appears in the main README.md table
4. **Tag Creation**: If using new tags, verify `categorize/tags/newtag.md` is created
5. **Language Categorization**: Verify tool appears in `categorize/langs/Language.md`

## Timing Expectations
- YAML linting: ~1 second for all 409 files
- Build script: ~0.3 seconds to generate all documentation
- Validation script: ~0.1 seconds to check all weapons
- **Total validation time: ~1.5 seconds**

## Development Notes
- The repository contains 409+ weapon definitions
- 73 different tags for categorization
- 19 programming languages represented
- All documentation is auto-generated from YAML source files
- Images are stored in `/images/` directory for badges and logos

## Troubleshooting Workflows

### Complete Weapon Addition Workflow
```bash
# 1. Create weapon file
cat > weapons/newtool.yaml << EOF
---
name: New Tool
description: Description of the tool
url: https://github.com/owner/repo
category: tool
type: Scanner
platform: [linux, macos, windows]
lang: Python
tags: [xss]
EOF

# 2. Validate YAML syntax
yamllint weapons/newtool.yaml

# 3. Build documentation
ruby ./scripts/erb.rb

# 4. Verify tool appears in README
grep "New Tool" README.md

# 5. Check validation warnings
ruby ./scripts/validate_weapons.rb
```

### CI/CD Validation Process
The GitHub Actions workflows automatically:
1. **On PR**: Run `yamllint weapons/*.yaml` 
2. **On merge to main**: Run `ruby ./scripts/erb.rb` and commit changes

## Git Workflow Best Practices
- **Fork the repository** before making changes
- **Create feature branches** for new weapons or modifications
- **Test locally** before pushing:
  ```bash
  yamllint weapons/*.yaml
  ruby ./scripts/erb.rb
  git status  # Check what files changed
  ```
- **Commit only** `weapons/*.yaml` changes in PRs
- **Never commit** auto-generated `README.md` or `categorize/*` files in PRs

## Do NOT Modify
**These files are auto-generated and will be overwritten:**
- `README.md`
- All files in `categorize/langs/`
- All files in `categorize/tags/`

**Only modify these directories:**
- `weapons/` -- Add new weapon YAML files
- `scripts/` -- Modify generation scripts (advanced users only)
- `images/` -- Add new badges or logos