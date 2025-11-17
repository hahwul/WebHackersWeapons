#!/usr/bin/env python3
"""
WebHackersWeapons MCP Server

An MCP (Model Context Protocol) server that provides access to the
WebHackersWeapons security tools catalog.

Exposes tools for searching, filtering, and discovering security tools.
"""

import json
import yaml
import os
import re
from typing import List, Dict, Any, Optional
from pathlib import Path
from datetime import datetime
from mcp.server import Server
from mcp.types import Tool, TextContent


class WebHackersWeaponsMCP:
    """MCP Server for WebHackersWeapons catalog"""

    def __init__(self, weapons_dir: str = "./weapons"):
        self.weapons_dir = Path(weapons_dir)
        self.tools_cache = None
        self._load_tools()

    def _load_tools(self) -> None:
        """Load all weapon YAML files into memory"""
        tools = []

        for yaml_file in sorted(self.weapons_dir.glob("*.yaml")):
            try:
                with open(yaml_file, 'r') as f:
                    tool = yaml.safe_load(f)

                if tool is None:
                    continue

                # Add metadata
                tool['_meta'] = {
                    'filename': yaml_file.name,
                    'last_modified': datetime.fromtimestamp(
                        yaml_file.stat().st_mtime
                    ).isoformat()
                }

                # Extract GitHub repo if applicable
                if tool.get('url') and 'github.com' in tool['url']:
                    match = re.search(r'github\.com/([^/]+/[^/]+)', tool['url'])
                    if match:
                        tool['_meta']['github_repo'] = match.group(1).rstrip('/')

                tools.append(tool)

            except Exception as e:
                print(f"Error loading {yaml_file}: {e}")

        self.tools_cache = tools
        print(f"Loaded {len(tools)} tools")

    def search_tools(self, query: str, limit: int = 10) -> List[Dict]:
        """
        Search tools by name, description, or URL

        Args:
            query: Search query string
            limit: Maximum number of results to return

        Returns:
            List of matching tools
        """
        query_lower = query.lower()
        results = []

        for tool in self.tools_cache:
            # Search in name, description, and URL
            if (query_lower in tool.get('name', '').lower() or
                query_lower in tool.get('description', '').lower() or
                query_lower in tool.get('url', '').lower()):
                results.append(tool)

            if len(results) >= limit:
                break

        return results

    def get_tools_by_tag(self, tag: str) -> List[Dict]:
        """
        Get all tools with a specific tag

        Args:
            tag: Tag name (e.g., 'xss', 'sqli', 'subdomains')

        Returns:
            List of tools with the specified tag
        """
        return [
            tool for tool in self.tools_cache
            if tool.get('tags') and tag in tool['tags']
        ]

    def get_tools_by_language(self, language: str) -> List[Dict]:
        """
        Get all tools written in a specific language

        Args:
            language: Programming language (e.g., 'Go', 'Python', 'Rust')

        Returns:
            List of tools written in the specified language
        """
        return [
            tool for tool in self.tools_cache
            if tool.get('lang') and tool['lang'].lower() == language.lower()
        ]

    def get_tools_by_type(self, tool_type: str) -> List[Dict]:
        """
        Get all tools of a specific type

        Args:
            tool_type: Tool type (e.g., 'Scanner', 'Recon', 'Fuzzer')

        Returns:
            List of tools of the specified type
        """
        return [
            tool for tool in self.tools_cache
            if tool.get('type') and tool['type'].lower() == tool_type.lower()
        ]

    def filter_tools(
        self,
        platform: Optional[str] = None,
        tool_type: Optional[str] = None,
        language: Optional[str] = None,
        tags: Optional[List[str]] = None
    ) -> List[Dict]:
        """
        Advanced filtering with multiple criteria

        Args:
            platform: Platform filter (linux, macos, windows, etc.)
            tool_type: Tool type filter
            language: Programming language filter
            tags: List of required tags (ALL must match)

        Returns:
            List of tools matching all specified criteria
        """
        results = self.tools_cache

        if platform:
            results = [
                t for t in results
                if t.get('platform') and platform in t['platform']
            ]

        if tool_type:
            results = [
                t for t in results
                if t.get('type') and t['type'].lower() == tool_type.lower()
            ]

        if language:
            results = [
                t for t in results
                if t.get('lang') and t['lang'].lower() == language.lower()
            ]

        if tags:
            for tag in tags:
                results = [
                    t for t in results
                    if t.get('tags') and tag in t['tags']
                ]

        return results

    def get_tool_details(self, name: str) -> Optional[Dict]:
        """
        Get complete information about a specific tool

        Args:
            name: Tool name (case-insensitive)

        Returns:
            Tool object or None if not found
        """
        name_lower = name.lower()
        for tool in self.tools_cache:
            if tool.get('name', '').lower() == name_lower:
                return tool
        return None

    def list_tags(self) -> List[Dict[str, Any]]:
        """
        Get all available tags with tool counts

        Returns:
            List of tags with counts, sorted by count descending
        """
        tag_counts = {}

        for tool in self.tools_cache:
            if tool.get('tags'):
                for tag in tool['tags']:
                    tag_counts[tag] = tag_counts.get(tag, 0) + 1

        return [
            {'tag': tag, 'count': count}
            for tag, count in sorted(tag_counts.items(), key=lambda x: -x[1])
        ]

    def list_languages(self) -> List[Dict[str, Any]]:
        """
        Get all languages with tool counts

        Returns:
            List of languages with counts, sorted by count descending
        """
        lang_counts = {}

        for tool in self.tools_cache:
            lang = tool.get('lang')
            if lang:
                lang_counts[lang] = lang_counts.get(lang, 0) + 1

        return [
            {'language': lang, 'count': count}
            for lang, count in sorted(lang_counts.items(), key=lambda x: -x[1])
        ]

    def get_statistics(self) -> Dict[str, Any]:
        """
        Get catalog statistics

        Returns:
            Dictionary with comprehensive statistics
        """
        stats = {
            'total_tools': len(self.tools_cache),
            'by_type': {},
            'by_language': {},
            'by_category': {},
            'platforms': {},
            'total_tags': 0,
            'total_languages': 0
        }

        # Count by type
        for tool in self.tools_cache:
            tool_type = tool.get('type', 'unknown')
            stats['by_type'][tool_type] = stats['by_type'].get(tool_type, 0) + 1

            # Count by language
            lang = tool.get('lang')
            if lang:
                stats['by_language'][lang] = stats['by_language'].get(lang, 0) + 1

            # Count by category
            cat = tool.get('category', 'unknown')
            stats['by_category'][cat] = stats['by_category'].get(cat, 0) + 1

            # Count platforms
            if tool.get('platform'):
                for platform in tool['platform']:
                    stats['platforms'][platform] = stats['platforms'].get(platform, 0) + 1

        stats['total_tags'] = len(self.list_tags())
        stats['total_languages'] = len(stats['by_language'])

        return stats

    def recommend_tools(self, use_case: str) -> List[Dict]:
        """
        AI-powered tool recommendations based on use case

        Args:
            use_case: Description of what you want to accomplish

        Returns:
            List of recommended tools with relevance scores
        """
        use_case_lower = use_case.lower()

        # Keyword to tag mapping
        keyword_tags = {
            'subdomain': ['subdomains', 'recon', 'dns'],
            'xss': ['xss', 'vulnerability-scanner'],
            'sqli': ['sqli', 'vulnerability-scanner'],
            'sql injection': ['sqli', 'vulnerability-scanner'],
            'ssrf': ['ssrf', 'vulnerability-scanner'],
            'fuzzing': ['fuzz', 'fuzzer'],
            'proxy': ['mitmproxy', 'proxy'],
            'javascript': ['js-analysis', 'endpoint'],
            'api': ['graphql', 'api', 'endpoint'],
            'parameter': ['param', 'fuzzer'],
            'crawler': ['crawl', 'recon'],
            'screenshot': ['screenshot', 'recon'],
            'port scan': ['portscan', 'network'],
            'secret': ['secret-scanning', 'credentials'],
        }

        # Find matching tags
        relevant_tags = set()
        for keyword, tags in keyword_tags.items():
            if keyword in use_case_lower:
                relevant_tags.update(tags)

        # Score tools based on tag matches
        scored_tools = []
        for tool in self.tools_cache:
            score = 0
            tool_tags = set(tool.get('tags', []))

            # Count matching tags
            matches = tool_tags & relevant_tags
            score = len(matches)

            # Boost score for keywords in name/description
            if any(keyword in tool.get('name', '').lower() for keyword in use_case_lower.split()):
                score += 2
            if any(keyword in tool.get('description', '').lower() for keyword in use_case_lower.split()):
                score += 1

            if score > 0:
                tool_copy = tool.copy()
                tool_copy['_relevance_score'] = score
                scored_tools.append(tool_copy)

        # Sort by score and return top 10
        scored_tools.sort(key=lambda x: x['_relevance_score'], reverse=True)
        return scored_tools[:10]


# MCP Server Setup
app = Server("webhackersweapons")
whw = WebHackersWeaponsMCP()


@app.list_tools()
async def list_tools() -> List[Tool]:
    """List all available MCP tools"""
    return [
        Tool(
            name="search_tools",
            description="Search security tools by name, description, or URL",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {
                        "type": "string",
                        "description": "Search query (searches name, description, URL)"
                    },
                    "limit": {
                        "type": "number",
                        "description": "Maximum results to return",
                        "default": 10
                    }
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="get_tools_by_tag",
            description="Find all tools for a specific vulnerability or technique",
            inputSchema={
                "type": "object",
                "properties": {
                    "tag": {
                        "type": "string",
                        "description": "Tag name (e.g., xss, sqli, subdomains)"
                    }
                },
                "required": ["tag"]
            }
        ),
        Tool(
            name="get_tools_by_language",
            description="Find all tools written in a specific programming language",
            inputSchema={
                "type": "object",
                "properties": {
                    "language": {
                        "type": "string",
                        "description": "Programming language (e.g., Go, Python, Rust)"
                    }
                },
                "required": ["language"]
            }
        ),
        Tool(
            name="get_tools_by_type",
            description="Find tools by category (Recon, Scanner, Fuzzer, etc.)",
            inputSchema={
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "description": "Tool type",
                        "enum": ["Army-Knife", "Proxy", "Recon", "Fuzzer", "Scanner", "Exploit", "Env", "Utils", "Etc"]
                    }
                },
                "required": ["type"]
            }
        ),
        Tool(
            name="filter_tools",
            description="Advanced filtering with multiple criteria",
            inputSchema={
                "type": "object",
                "properties": {
                    "platform": {
                        "type": "string",
                        "description": "Platform filter (linux, macos, windows, etc.)"
                    },
                    "type": {
                        "type": "string",
                        "description": "Tool type filter"
                    },
                    "language": {
                        "type": "string",
                        "description": "Programming language filter"
                    },
                    "tags": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Must have ALL these tags"
                    }
                }
            }
        ),
        Tool(
            name="get_tool_details",
            description="Get complete information about a specific tool",
            inputSchema={
                "type": "object",
                "properties": {
                    "name": {
                        "type": "string",
                        "description": "Tool name (case-insensitive)"
                    }
                },
                "required": ["name"]
            }
        ),
        Tool(
            name="list_tags",
            description="Get all available tags with tool counts",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="list_languages",
            description="Get all languages with tool counts",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="get_statistics",
            description="Get catalog statistics and metrics",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="recommend_tools",
            description="Get AI-powered tool recommendations based on use case",
            inputSchema={
                "type": "object",
                "properties": {
                    "use_case": {
                        "type": "string",
                        "description": "What you want to accomplish"
                    }
                },
                "required": ["use_case"]
            }
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> List[TextContent]:
    """Handle tool calls"""

    try:
        if name == "search_tools":
            results = whw.search_tools(
                arguments.get("query"),
                arguments.get("limit", 10)
            )

        elif name == "get_tools_by_tag":
            results = whw.get_tools_by_tag(arguments["tag"])

        elif name == "get_tools_by_language":
            results = whw.get_tools_by_language(arguments["language"])

        elif name == "get_tools_by_type":
            results = whw.get_tools_by_type(arguments["type"])

        elif name == "filter_tools":
            results = whw.filter_tools(
                platform=arguments.get("platform"),
                tool_type=arguments.get("type"),
                language=arguments.get("language"),
                tags=arguments.get("tags")
            )

        elif name == "get_tool_details":
            results = whw.get_tool_details(arguments["name"])

        elif name == "list_tags":
            results = whw.list_tags()

        elif name == "list_languages":
            results = whw.list_languages()

        elif name == "get_statistics":
            results = whw.get_statistics()

        elif name == "recommend_tools":
            results = whw.recommend_tools(arguments["use_case"])

        else:
            return [TextContent(
                type="text",
                text=f"Unknown tool: {name}"
            )]

        # Format results as JSON
        return [TextContent(
            type="text",
            text=json.dumps(results, indent=2)
        )]

    except Exception as e:
        return [TextContent(
            type="text",
            text=f"Error: {str(e)}"
        )]


async def main():
    """Run the MCP server"""
    from mcp.server.stdio import stdio_server

    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
