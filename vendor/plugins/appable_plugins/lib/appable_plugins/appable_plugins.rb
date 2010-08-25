module PluginAWeek #:nodoc:
  # Gives all plugins the ability to automatically mix in models, controllers,
  # helpers, and non-standard classes from their own app folder.
  module AppablePlugins
    def self.included(base) #:nodoc:
      # We want to get in between loaded_plugins and the original implementation
      # since we use loaded plugins
      base.class_eval do
        alias_method :after_initialize_without_appable_plugins, :after_initialize_without_loaded_plugins
        alias_method :after_initialize_without_loaded_plugins, :after_initialize_with_appable_plugins
      end
      
      # Support paths for plugins already loaded
      Rails.plugins.each {|plugin| plugin.inject_dependencies}
    end
    
    # Map the application's app folders to their actual namespaces
    def after_initialize_with_appable_plugins #:nodoc:
      main_app_paths = Dependencies.send(:find_main_app_directories)
      main_app_paths.each do |path|
        path.chop! if path.ends_with?('/')
        path = File.expand_path(path)
        
        if path =~ /app\/([^\/]+)(\/(.*))?$/
          type = $1.to_sym
          base_directory = $3
          Dependencies.mixable_app_types[type] ||= /.+/
          
          map_application_namespaces(path, type, main_app_paths - [path], base_directory)
        end
      end
      
      after_initialize_without_appable_plugins
    end
    
    # Map the application's app folders to their actual namespaces
    def map_application_namespaces(path, type, paths_to_skip, base_directory, base_path = path)
      return if paths_to_skip.include?(path)
      
      # Our namespace is equal to our path - the original base path, e.g.
      # base_path: /app/models/account
      # path: /app/models/account/abc/xyz
      # namespace: abc/xyz
      namespace = path[base_path.length+1..-1] || ''
      
      # Map the entire directory to the namespace, e.g. /account/abc/xyz would
      # be mapped to abc/xyz
      unless base_directory.blank? && namespace.blank?
        if namespace.blank?
          subdirectory = base_directory
        elsif base_directory.blank?
          subdirectory = namespace
        else
          subdirectory = "#{base_directory}/#{namespace}"
        end
        
        type_namespaces = Dependencies.app_namespaces[type] ||= {}
        type_namespaces[subdirectory] = namespace
      end
      
      Dir["#{path}/*/"].sort.each do |subdirectory|
        map_application_namespaces(subdirectory.chop, type, paths_to_skip, base_directory, base_path)
      end
    end
  end
end