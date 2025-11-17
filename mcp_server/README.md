# WebHackersWeapons MCP Server

An MCP (Model Context Protocol) server that provides Claude with access to the WebHackersWeapons security tools catalog.

## Overview

This MCP server exposes **10 tools** for discovering, searching, and filtering 423+ security tools used by web hackers, bug bounty hunters, and penetration testers.

### What is MCP?

The Model Context Protocol (MCP) allows Claude to interact with external data sources and tools. This server makes the entire WebHackersWeapons catalog queryable by Claude in real-time.

## Features

### Available Tools

1. **search_tools** - Search by name, description, or URL
2. **get_tools_by_tag** - Find tools for specific vulnerabilities (XSS, SQLi, SSRF, etc.)
3. **get_tools_by_language** - Filter by programming language (Go, Python, Rust, etc.)
4. **get_tools_by_type** - Find tools by category (Scanner, Recon, Fuzzer, etc.)
5. **filter_tools** - Advanced multi-criteria filtering
6. **get_tool_details** - Get complete information about a specific tool
7. **list_tags** - Browse all available tags with counts
8. **list_languages** - Browse all languages with counts
9. **get_statistics** - Get catalog statistics and metrics
10. **recommend_tools** - AI-powered recommendations based on use case

## Installation

### Prerequisites

- Python 3.8+
- pip

### Install Dependencies

```bash
cd mcp_server
pip install -r requirements.txt
```

## Usage

### Running the Server

The MCP server runs via stdio:

```bash
python server.py
```

### Configuration for Claude Desktop

Add to your Claude Desktop configuration:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "webhackersweapons": {
      "command": "python",
      "args": ["/absolute/path/to/WebHackersWeapons/mcp_server/server.py"],
      "env": {}
    }
  }
}
```

### Example Queries to Claude

Once configured, you can ask Claude:

**Search for tools:**
> "Find subdomain enumeration tools"
> "Show me all XSS testing tools"
> "Search for nuclei"

**Filter by criteria:**
> "What Go-based reconnaissance tools are available?"
> "Show me Python vulnerability scanners that work on Linux"
> "Find tools with both 'xss' and 'vulnerability-scanner' tags"

**Get recommendations:**
> "I need to find all subdomains of a target and test them for XSS"
> "Recommend tools for API security testing"
> "What tools should I use for JavaScript analysis?"

**Get statistics:**
> "How many tools are in the catalog?"
> "What are the most popular tags?"
> "Show me language distribution statistics"

## Tool Examples

### 1. search_tools

Search for tools by keyword:

```json
{
  "query": "subdomain",
  "limit": 5
}
```

Returns:
```json
[
  {
    "name": "subfinder",
    "description": "Subdomain discovery tool",
    "url": "https://github.com/projectdiscovery/subfinder",
    "type": "Recon",
    "platform": ["linux", "macos", "windows"],
    "lang": "Go",
    "tags": ["subdomains"]
  }
]
```

### 2. get_tools_by_tag

Find all XSS tools:

```json
{
  "tag": "xss"
}
```

### 3. filter_tools

Advanced filtering:

```json
{
  "platform": "linux",
  "type": "Scanner",
  "language": "Go",
  "tags": ["vulnerability-scanner"]
}
```

### 4. recommend_tools

Get AI recommendations:

```json
{
  "use_case": "I need to find all subdomains and check for takeover vulnerabilities"
}
```

Returns tools ranked by relevance with scores.

## Architecture

### Data Flow

```
YAML Files → Python Loader → In-Memory Cache → MCP Tools → Claude
```

1. **Loading:** Server loads all 423 YAML files on startup
2. **Caching:** Tools kept in memory for fast queries
3. **Querying:** MCP tools provide various query interfaces
4. **Response:** Results returned as JSON to Claude

### Performance

- **Cold start:** ~1 second to load all tools
- **Query time:** <10ms for most queries (in-memory)
- **Memory usage:** ~5MB for full catalog

## Development

### Testing Locally

```python
from server import WebHackersWeaponsMCP

# Initialize
whw = WebHackersWeaponsMCP("../weapons")

# Search
results = whw.search_tools("nuclei")
print(results)

# Get by tag
xss_tools = whw.get_tools_by_tag("xss")
print(f"Found {len(xss_tools)} XSS tools")

# Statistics
stats = whw.get_statistics()
print(f"Total tools: {stats['total_tools']}")
```

### Adding New Tools

New tools added to `weapons/*.yaml` are automatically picked up on server restart.

## Troubleshooting

### Server won't start

**Check Python version:**
```bash
python --version  # Should be 3.8+
```

**Reinstall dependencies:**
```bash
pip install -r requirements.txt --force-reinstall
```

### Tools not loading

**Check file path:**
```python
# In server.py, verify weapons_dir path
whw = WebHackersWeaponsMCP("../weapons")  # Relative to mcp_server/
```

**Verify YAML files:**
```bash
ls ../weapons/*.yaml | wc -l  # Should show 423
```

### Claude can't find the server

1. Check configuration path is absolute
2. Restart Claude Desktop
3. Check Claude Desktop logs

## Extending the Server

### Add a New Tool

Example: Add tool to count tools by platform

```python
def count_by_platform(self) -> Dict[str, int]:
    """Count tools by platform"""
    platform_counts = {}
    for tool in self.tools_cache:
        if tool.get('platform'):
            for platform in tool['platform']:
                platform_counts[platform] = platform_counts.get(platform, 0) + 1
    return platform_counts
```

Then add to MCP tools list and call_tool handler.

## Security

### Safe YAML Loading

The server uses `yaml.safe_load()` to prevent arbitrary code execution.

### No External Requests

The server operates entirely on local data - no external API calls.

## Performance Optimization

### Current Optimizations

- In-memory caching of all tools
- O(n) search complexity (acceptable for 423 tools)
- No database overhead

### Future Improvements

- [ ] Index by tags for O(1) tag lookups
- [ ] Full-text search with ranking
- [ ] Caching for complex queries
- [ ] Incremental loading for large catalogs

## Contributing

See main [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines.

## License

Same as main project - see [LICENSE](../LICENSE)

---

## Example Conversation with Claude

**User:** "I'm doing a bug bounty and need to enumerate subdomains. What tools should I use?"

**Claude (using MCP):**
*Calls `recommend_tools` with use_case="enumerate subdomains"*

"Based on the WebHackersWeapons catalog, here are the top subdomain enumeration tools:

1. **subfinder** (Go) - Fast passive subdomain discovery
2. **amass** (Go) - In-depth attack surface mapping
3. **assetfinder** (Go) - Find related domains and subdomains
4. **findomain** (Rust) - Cross-platform subdomain enumerator
5. **knock** (Python) - Subdomain scanner

All of these are available for Linux/macOS/Windows. Would you like details on any specific tool?"

---

**Ready to use!** Configure in Claude Desktop and start querying the catalog.
