require 'yaml'

Dir.entries("./weapons").each do | name |
    # Skip hidden files and directories
    next if name.start_with?('.')

    if name.strip != "."  || name != ".."
      begin
        data = YAML.safe_load(File.open("./weapons/#{name}"))

        # Skip if data is nil (directory entries)
        next if data.nil?

        # Check for missing type
        if data['type'].nil? || data['type'].to_s.strip.empty?
            puts "./weapons/#{name} :: none-type"
        end

        # Check for missing language (GitHub projects only)
        if data['lang'].nil? || data['lang'].to_s.strip.empty?
          if data['url']&.include?("github.com")
            puts "./weapons/#{name} :: none-lang"
          end
        end

        # Check for missing tags
        if data['tags'].nil? || data['tags'].empty?
            #puts "#{name} :: none-tags"
        end
      rescue StandardError => e
        STDERR.puts "Error validating ./weapons/#{name}: #{e.message}"
      end
    end
end