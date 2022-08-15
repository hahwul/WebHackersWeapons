require 'json'
require 'yaml'
require "uri"

def get_os install
     lst = []
     if install['Linux'].length > 1
          lst.push 'linux'
     end
     if install['MacOS'].length > 1
          lst.push 'macos'
     end
     if install['Windows'].length > 1
          lst.push 'windows'
     end
     return lst
end

def get_browser str
     lst = []
     if str.include? 'Chrome'
          lst.push 'chrome'
     end
     if str.include? 'Firefox'
          lst.push 'firefox'
     end
     if str.include? 'Safari'
          lst.push 'safari'
     end
     if str.include? 'Burp'
          lst.push 'burpsuite'
     end
     if str.include? 'ZAP'
          lst.push 'zap'
     end
     if str.include? 'All'
          lst.push 'burpsuite'
          lst.push 'zap'
     end
     return lst
end

def get_urls str
     return URI.extract(str).uniq
end

def migrate jsonfile, category
     file = File.read(jsonfile)
     data_hash = JSON.parse(file)

     data_hash.each do | name, obj |
          filename = name.gsub(' ','_')+".yaml"
          # Make object
          new_obj = {}
          new_obj['name'] = name
          new_obj['description'] = obj['Description']
          new_obj['urls'] = get_urls obj['Data']
          new_obj['category'] = category
          new_obj['types'] = []
          if obj['Install'] != nil 
               new_obj['platform'] = get_os(obj['Install'])
          end
          if category.include? 'addon'
               if obj['Type'].length > 0 
                    new_obj['platform'] = get_browser(obj['Type'])
               end
          end
          new_obj['lang'] = [] # parse DATA
          new_obj['tags'] = []

          # Convert to YAML
          yaml_data = YAML.dump(new_obj)

          # Save yaml file
          puts filename
          #File.write("./weapons/#{filename}", yaml_data)
     end
end 

migrate './data.json', 'tool'
migrate './Bookmarklets/data.json', 'bookmarklet'
migrate './Browser Extensions/data.json', 'browser-addon'
migrate './Burp and ZAP Extensions/data.json', 'tool-addon'