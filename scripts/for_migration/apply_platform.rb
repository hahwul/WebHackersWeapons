require 'yaml'

Dir.entries("./weapons").each do | name |
    if name.strip != "."  || name != ".."
      begin
        data = YAML.load(File.open("./weapons/#{name}"))
        data['platform'] = ['linux','macos','windows']
        yaml_data = YAML.dump(data)
        File.write("./weapons/#{name}", yaml_data)
      rescue => e
        puts e
      end
    end
end