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
               new_obj['os'] = get_os(obj['Install'])
          end
          new_obj['lang'] = [] # parse DATA
          new_obj['tags'] = []

          # Convert to YAML
          yaml_data = YAML.dump(new_obj)

          # Save yaml file
          puts filename
          #File.write("./data/#{filename}", yaml_data)
     end
end 

migrate './data.json', 'tool'
migrate './Bookmarklets/data.json', 'bookmarklet'
migrate './Browser Extensions/data.json', 'browser-addon'
migrate './Burp and ZAP Extensions/data.json', 'tool-addon'