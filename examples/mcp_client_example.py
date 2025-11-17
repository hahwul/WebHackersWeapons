#!/usr/bin/env python3
"""
Example client demonstrating WebHackersWeapons MCP server usage
"""

import sys
sys.path.insert(0, '../mcp_server')

from server import WebHackersWeaponsMCP


def print_section(title):
    """Print a formatted section header"""
    print(f"\n{'=' * 60}")
    print(f"{title}")
    print('=' * 60)


def main():
    """Run example queries"""
    print("WebHackersWeapons MCP Server - Usage Examples")

    # Initialize
    print("\nInitializing server...")
    whw = WebHackersWeaponsMCP("../weapons")

    # Example 1: Search
    print_section("Example 1: Search for 'nuclei'")
    results = whw.search_tools("nuclei", limit=3)
    for tool in results:
        print(f"\n{tool['name']}")
        print(f"  Description: {tool['description']}")
        print(f"  URL: {tool['url']}")
        print(f"  Type: {tool['type']}")
        print(f"  Language: {tool.get('lang', 'N/A')}")

    # Example 2: Get tools by tag
    print_section("Example 2: Find XSS tools")
    xss_tools = whw.get_tools_by_tag("xss")
    print(f"Found {len(xss_tools)} XSS tools")
    for tool in xss_tools[:3]:
        print(f"  - {tool['name']}: {tool['description'][:60]}...")

    # Example 3: Get tools by language
    print_section("Example 3: Find Rust tools")
    rust_tools = whw.get_tools_by_language("Rust")
    print(f"Found {len(rust_tools)} Rust tools")
    for tool in rust_tools[:5]:
        print(f"  - {tool['name']}")

    # Example 4: Get tools by type
    print_section("Example 4: Find Scanner tools")
    scanners = whw.get_tools_by_type("Scanner")
    print(f"Found {len(scanners)} Scanner tools")
    for tool in scanners[:5]:
        print(f"  - {tool['name']}")

    # Example 5: Advanced filtering
    print_section("Example 5: Filter (Go + Recon + Linux)")
    filtered = whw.filter_tools(
        platform="linux",
        tool_type="Recon",
        language="Go"
    )
    print(f"Found {len(filtered)} tools matching all criteria:")
    for tool in filtered[:5]:
        print(f"  - {tool['name']}")

    # Example 6: Get tool details
    print_section("Example 6: Get details for 'subfinder'")
    tool = whw.get_tool_details("subfinder")
    if tool:
        print(f"Name: {tool['name']}")
        print(f"Description: {tool['description']}")
        print(f"URL: {tool['url']}")
        print(f"Type: {tool['type']}")
        print(f"Language: {tool.get('lang')}")
        print(f"Platforms: {', '.join(tool['platform'])}")
        print(f"Tags: {', '.join(tool.get('tags', []))}")

    # Example 7: List tags
    print_section("Example 7: Top 10 most popular tags")
    tags = whw.list_tags()
    for tag_info in tags[:10]:
        print(f"  {tag_info['tag']}: {tag_info['count']} tools")

    # Example 8: List languages
    print_section("Example 8: Top 10 languages")
    languages = whw.list_languages()
    for lang_info in languages[:10]:
        print(f"  {lang_info['language']}: {lang_info['count']} tools")

    # Example 9: Statistics
    print_section("Example 9: Catalog statistics")
    stats = whw.get_statistics()
    print(f"Total tools: {stats['total_tools']}")
    print(f"\nTop 5 by type:")
    for tool_type, count in sorted(stats['by_type'].items(), key=lambda x: -x[1])[:5]:
        print(f"  {tool_type}: {count}")
    print(f"\nTop 5 by language:")
    for lang, count in sorted(stats['by_language'].items(), key=lambda x: -x[1])[:5]:
        print(f"  {lang}: {count}")
    print(f"\nTotal tags: {stats['total_tags']}")
    print(f"Total languages: {stats['total_languages']}")

    # Example 10: Recommendations
    print_section("Example 10: Get recommendations")
    use_case = "I need to find subdomains and test for XSS vulnerabilities"
    recommendations = whw.recommend_tools(use_case)
    print(f"Use case: {use_case}")
    print(f"\nTop 5 recommended tools:")
    for tool in recommendations[:5]:
        print(f"  {tool['name']} (score: {tool['_relevance_score']})")
        print(f"    {tool['description'][:70]}...")
        print(f"    Tags: {', '.join(tool.get('tags', []))}")

    print("\n" + "=" * 60)
    print("Examples completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()
