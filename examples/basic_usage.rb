#!/usr/bin/env ruby
# Basic usage examples for WebHackersWeapons scripts

require 'yaml'

puts "WebHackersWeapons - Basic Usage Examples"
puts "=" * 60

# Example 1: Load a single tool
puts "\n1. Loading a single tool:"
puts "-" * 60
tool = YAML.safe_load(File.read('./weapons/nuclei.yaml'))
puts "Name: #{tool['name']}"
puts "Description: #{tool['description']}"
puts "URL: #{tool['url']}"
puts "Language: #{tool['lang']}"
puts "Tags: #{tool['tags'].join(', ')}"

# Example 2: Load all tools
puts "\n2. Loading all tools:"
puts "-" * 60
tools = []
Dir.glob('./weapons/*.yaml').each do |file|
  tools << YAML.safe_load(File.read(file))
end
puts "Total tools loaded: #{tools.count}"

# Example 3: Find tools by tag
puts "\n3. Finding tools by tag (XSS):"
puts "-" * 60
xss_tools = tools.select { |t| t['tags']&.include?('xss') }
puts "Found #{xss_tools.count} XSS tools:"
xss_tools.first(5).each do |tool|
  puts "  - #{tool['name']}: #{tool['description']}"
end

# Example 4: Find tools by language
puts "\n4. Finding tools by language (Go):"
puts "-" * 60
go_tools = tools.select { |t| t['lang'] == 'Go' }
puts "Found #{go_tools.count} Go tools"
puts "Top 5:"
go_tools.first(5).each do |tool|
  puts "  - #{tool['name']}"
end

# Example 5: Find tools by type
puts "\n5. Finding tools by type (Scanner):"
puts "-" * 60
scanners = tools.select { |t| t['type'] == 'Scanner' }
puts "Found #{scanners.count} Scanner tools"
puts "Top 5:"
scanners.first(5).each do |tool|
  puts "  - #{tool['name']}: #{tool['description'][0..60]}..."
end

# Example 6: Find tools by platform
puts "\n6. Finding Linux-compatible tools:"
puts "-" * 60
linux_tools = tools.select { |t| t['platform']&.include?('linux') }
puts "Found #{linux_tools.count} Linux-compatible tools"

# Example 7: Complex filtering
puts "\n7. Complex filtering (Go + Recon + Linux):"
puts "-" * 60
filtered = tools.select do |t|
  t['lang'] == 'Go' &&
  t['type'] == 'Recon' &&
  t['platform']&.include?('linux')
end
puts "Found #{filtered.count} tools matching all criteria:"
filtered.first(5).each do |tool|
  puts "  - #{tool['name']}"
end

# Example 8: Statistics
puts "\n8. Catalog statistics:"
puts "-" * 60
type_counts = tools.group_by { |t| t['type'] }.transform_values(&:count)
lang_counts = tools.group_by { |t| t['lang'] }.transform_values(&:count)

puts "By Type:"
type_counts.sort_by { |_, count| -count }.first(5).each do |type, count|
  puts "  #{type}: #{count}"
end

puts "\nBy Language:"
lang_counts.sort_by { |_, count| -count }.first(5).each do |lang, count|
  puts "  #{lang}: #{count}"
end

puts "\n" + "=" * 60
puts "Examples completed!"
