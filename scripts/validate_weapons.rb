require 'yaml'

Dir.entries("./weapons").each do |name|
  next unless name.end_with?(".yaml")

  begin
    data = YAML.load(File.open("./weapons/#{name}"))
    if data['type'].to_s.empty?
      puts "./weapons/#{name} :: none-type"
    end
    if data['lang'].to_s.empty?
      if data['url'].to_s.include?("github.com")
        puts "./weapons/#{name} :: none-lang"
      end
    end
    tags = data['tags']
    if tags.nil? || tags.length == 0
      # puts "./weapons/#{name} :: none-tags"
    end
  rescue => e
    puts "#{name} :: #{e}"
  end
end
