# weapons

Terminal client for the [WebHackersWeapons](https://github.com/hahwul/WebHackersWeapons) catalog. Browses, searches, and filters the same JSON API the static site exposes, with a local cache so repeat queries are instant.

## Install

```sh
cd cli
shards build --release
# binary at ./bin/weapons — copy to ~/.local/bin or /usr/local/bin
```

Crystal 1.20+ required. The CLI has no external shard dependencies.

## Usage

```
weapons search <keyword>            # fuzzy match name/description/tags
weapons list                        # everything in the catalog
weapons info <name|slug>            # detail on one weapon
weapons random                      # pick one
weapons category <name>             # list by category
weapons stats                       # type/lang/category counts
weapons tags                        # tag histogram
weapons update                      # force-refresh the local cache
```

All read commands accept the same filters:

```
--type <T>       Utils | Recon | Scanner | Fuzzer | Exploit | Proxy | Army-Knife | Env
--category <C>   tool | tool-addon | browser-addon
--lang <L>       Go, Python, Rust, ...
--platform <P>   linux | macos | windows | firefox | chrome | safari | burpsuite | zap | caido
--tag <T>
-n, --limit <N>
```

Examples:

```sh
weapons search subdomain --type Recon --lang Go
weapons list --platform burpsuite
weapons random --type Scanner
weapons info dalfox --json | jq '.url'
```

## Data source

By default the CLI fetches `https://weapons.hahwul.com/api/weapons.json` and caches the response at `~/.cache/weapons/weapons.json` for 24 hours. Override:

- `--api-url <URL>` or `WEAPONS_API_URL=<URL>`
- `--data <path>` — read a local JSON file (skips HTTP + cache)
- `--refresh` — bypass the cache once; `weapons update` clears it permanently
- `--strict` — fail on network error instead of falling back to the cached copy (default: fall back with a warning)

For offline dev against a freshly built site:

```sh
weapons --data ../web/public/api/weapons.json list
```

## Development

```sh
shards build           # debug build at bin/weapons
crystal spec           # fixture-backed end-to-end tests
```

Specs drive the compiled binary against `spec/fixtures/weapons.json`; rebuild after code changes.
