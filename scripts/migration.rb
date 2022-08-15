require 'json'

file = File.read('./data.json')
data_hash = JSON.parse(file)

data_hash.each do | name, obj |
     puts "filename: "+name+".yaml"

     # Make object
     obj = {}
     obj['name'] = name
     obj['description'] = obj['Description']
     obj['url'] = '' # parse DATA
     obj['category'] = 'tool'
     obj['types'] = []
     obj['lang'] = [] # parse DATA
     obj['tags'] = []
     
     # Save file
end