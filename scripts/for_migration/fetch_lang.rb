# https://api.github.com/repos/hahwul/dalfox/languages
#
#
require 'yaml'

langs = []
Dir.entries("./weapons").each do | name |
    if name.strip != "."  || name != ".."
      begin
        data = YAML.load(File.open("./weapons/#{name}"))
        if data['url'].include? "//github.com"
            t = data['url'].split("/")
            lang = `curl -s https://api.github.com/repos/#{t[3]}/#{t[4]}/languages | jq 'to_entries | max_by(.value) | .key'`
            lang_str = lang.gsub("\"","").gsub("\n","")
            if lang_str != "documentation_url"
              puts "hit #{name}"
              data['lang'] = lang_str
              yaml_data = YAML.dump(data)
              File.write("./weapons/#{name}", yaml_data)
              langs.push lang_str
            else
              puts "denied #{name}"
            end
            sleep(90)
        end
      rescue => e
        puts e
      end
    end
  end
puts langs.uniq