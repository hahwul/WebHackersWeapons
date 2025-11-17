#!/usr/bin/env ruby
# Detect duplicate tools by URL or name

require 'yaml'

class DuplicateDetector
  def initialize(weapons_dir = './weapons')
    @weapons_dir = weapons_dir
  end

  def detect
    urls = {}
    names = {}
    errors = []
    total_files = 0

    Dir.glob("#{@weapons_dir}/*.yaml").each do |file|
      total_files += 1
      begin
        data = YAML.safe_load(File.read(file))
        next if data.nil?

        # Check duplicate URLs
        if data['url'] && !data['url'].empty?
          normalized_url = normalize_url(data['url'])
          if urls[normalized_url]
            errors << {
              type: 'duplicate_url',
              url: data['url'],
              files: [urls[normalized_url], file]
            }
            puts "❌ DUPLICATE URL: #{normalized_url}"
            puts "   File 1: #{urls[normalized_url]}"
            puts "   File 2: #{file}"
            puts
          else
            urls[normalized_url] = file
          end
        end

        # Check duplicate names (case-insensitive)
        if data['name'] && !data['name'].empty?
          normalized_name = data['name'].downcase.strip
          if names[normalized_name]
            errors << {
              type: 'duplicate_name',
              name: data['name'],
              files: [names[normalized_name], file]
            }
            puts "⚠️  DUPLICATE NAME: #{data['name']}"
            puts "   File 1: #{names[normalized_name]}"
            puts "   File 2: #{file}"
            puts
          else
            names[normalized_name] = file
          end
        end

      rescue StandardError => e
        STDERR.puts "Error processing #{file}: #{e.message}"
      end
    end

    # Summary
    puts "=" * 60
    puts "Duplicate Detection Summary"
    puts "=" * 60
    puts "Total files scanned: #{total_files}"
    puts "Unique URLs: #{urls.count}"
    puts "Unique names: #{names.count}"
    puts "Duplicates found: #{errors.count}"

    if errors.any?
      puts "\n⚠️  #{errors.count} duplicate(s) detected!"
      exit 1
    else
      puts "\n✓ No duplicates found"
      exit 0
    end
  end

  private

  def normalize_url(url)
    # Remove trailing slashes and .git extensions
    url.gsub(/\/$/, '').gsub(/\.git$/, '').downcase
  end
end

# Run if called directly
if __FILE__ == $PROGRAM_NAME
  puts "WebHackersWeapons Duplicate Detector"
  puts "=" * 60
  puts

  detector = DuplicateDetector.new
  detector.detect
end
