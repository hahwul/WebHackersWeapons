#!/usr/bin/env ruby
# Export weapons catalog to JSON format

require 'yaml'
require 'json'
require 'time'

class WeaponsExporter
  def initialize(weapons_dir = './weapons')
    @weapons_dir = weapons_dir
  end

  def export_all
    tools = []
    errors = []

    Dir.glob("#{@weapons_dir}/*.yaml").sort.each do |file|
      begin
        tool = YAML.safe_load(File.read(file))

        # Skip if nil
        next if tool.nil?

        # Add metadata
        tool['_meta'] = {
          'filename' => File.basename(file),
          'last_modified' => File.mtime(file).iso8601
        }

        # Enhance GitHub tools with metadata
        if tool['url']&.include?('github.com')
          repo = extract_github_repo(tool['url'])
          tool['_meta']['github_repo'] = repo if repo
        end

        tools << tool
      rescue StandardError => e
        errors << {file: file, error: e.message}
        STDERR.puts "Error processing #{file}: #{e.message}"
      end
    end

    puts "✓ Processed #{tools.count} tools"
    puts "✗ #{errors.count} errors" if errors.any?

    tools
  end

  def export_to_file(output_file = 'weapons.json')
    tools = export_all

    output = {
      'version' => '1.0',
      'generated_at' => Time.now.iso8601,
      'total_tools' => tools.count,
      'tools' => tools
    }

    File.write(output_file, JSON.pretty_generate(output))
    puts "✓ Exported #{tools.count} tools to #{output_file}"
  end

  def export_statistics(output_file = 'weapons_stats.json')
    tools = export_all

    # Calculate statistics
    stats = {
      'generated_at' => Time.now.iso8601,
      'total_tools' => tools.count,
      'by_type' => calculate_distribution(tools, 'type'),
      'by_category' => calculate_distribution(tools, 'category'),
      'by_language' => calculate_distribution(tools, 'lang'),
      'platforms' => count_platforms(tools),
      'tags' => count_tags(tools),
      'completeness' => {
        'with_tags' => tools.count { |t| t['tags'] && !t['tags'].empty? },
        'without_tags' => tools.count { |t| t['tags'].nil? || t['tags'].empty? },
        'with_lang' => tools.count { |t| t['lang'] && !t['lang'].to_s.empty? },
        'without_lang' => tools.count { |t| t['lang'].nil? || t['lang'].to_s.empty? }
      }
    }

    File.write(output_file, JSON.pretty_generate(stats))
    puts "✓ Exported statistics to #{output_file}"
  end

  private

  def extract_github_repo(url)
    match = url.match(%r{github\.com/([^/]+/[^/]+)})
    return nil unless match
    match[1].gsub(/\.git$/, '')
  end

  def calculate_distribution(tools, field)
    tools
      .group_by { |t| t[field] || 'unknown' }
      .transform_values(&:count)
      .sort_by { |_, count| -count }
      .to_h
  end

  def count_platforms(tools)
    platforms = Hash.new(0)
    tools.each do |tool|
      next unless tool['platform']
      tool['platform'].each { |p| platforms[p] += 1 }
    end
    platforms.sort_by { |_, count| -count }.to_h
  end

  def count_tags(tools)
    tags = Hash.new(0)
    tools.each do |tool|
      next unless tool['tags']
      tool['tags'].each { |t| tags[t] += 1 }
    end
    tags.sort_by { |_, count| -count }.first(50).to_h
  end
end

# Run if called directly
if __FILE__ == $PROGRAM_NAME
  exporter = WeaponsExporter.new

  puts "WebHackersWeapons JSON Exporter"
  puts "=" * 40

  exporter.export_to_file
  exporter.export_statistics

  puts "\n✓ Export complete!"
  puts "  - weapons.json: Complete tool catalog"
  puts "  - weapons_stats.json: Statistics and metrics"
end
