# Install hook code here
puts "installing the user plugin"
path = File.expand_path(File.dirname(__FILE__) + "/../plugin_migration_generator")
system("cd #{path}; rake generate_migration PLUGIN=user")