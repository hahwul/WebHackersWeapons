require 'json'

file = File.read('./data.json')
data_hash = JSON.parse(file)

data_hash.each do | name, obj |
     puts "filename: "+name+".yaml"
     puts obj['Description']

     # Make object
     # Save file
end