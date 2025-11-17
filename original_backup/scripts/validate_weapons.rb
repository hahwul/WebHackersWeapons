require 'yaml'

Dir.entries("./weapons").each do | name |
    if name.strip != "."  || name != ".."
      begin
        data = YAML.load(File.open("./weapons/#{name}"))
        if data['type'] == "" || data['type'] == nil
            puts "./weapons/#{name} :: none-type"
        end
        if data['lang'] == "" || data['lang'] == nil || data['lang'].length == 0
          if data['url'].include? "github.com"
            puts "./weapons/#{name} :: none-lang"
          end
        end
        if data['tags'].length == 0 || data['tags'] == nil
            #puts "#{name} :: none-tags"
        end
      rescue => e
        puts e
      end
    end
end