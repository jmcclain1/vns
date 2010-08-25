module PluginAWeek #:nodoc:
  # Keeps track of all the plugins that Rails loaded during initialization
  module LoadedPlugins
    mattr_accessor :plugins
    
    def self.included(base) #:nodoc:
      base.class_eval do
        alias_method_chain :load_plugin, :loaded_plugins
        alias_method_chain :after_initialize, :loaded_plugins
      end
    end
    
    def self.extended(initializer) #:nodoc:
      # Get all of the paths we missed before this plugin was loaded.  This is
      # only necessary for plugins that need +Rails.plugins+ during
      # initialization.
      add_loaded_plugins(initializer)
    end
    
    # Loads the plugin from the specified directory, tracking all successfully
    # loaded plugins in +Rails.plugins+
    def load_plugin_with_loaded_plugins(directory) #:nodoc:
      plugin = Plugin.new(directory)
      return false if Rails.plugins.include?(plugin)
      
      unless find_plugin_path(plugin.name).nil?
        # Be careful to place the plugin in the correct order in case a plugin
        # has required another plugin
        if @loaded_plugin_index
          Rails.plugins.insert(@loaded_plugin_index, plugin)
        else
          Rails.plugins << plugin
          @loaded_plugin_index = Rails.plugins.size - 1
        end
        
        # Plugin is about to be loaded
        plugin.before_load
      end
      
      load_plugin_without_loaded_plugins(directory)
      
      # Plugin has been loaded
      plugin.after_load
      
      # We no longer need to track the current index in LOADED_PLUGINS if we're
      # the last one
      @loaded_plugin_index = nil if Rails.plugins.last == plugin
      
      true
    end
    
    def after_initialize_with_loaded_plugins #:nodoc:
      add_loaded_plugins
      Rails.plugins.freeze
      Rails.plugins.each {|plugin| plugin.after_initialize}
      
      after_initialize_without_loaded_plugins
    end
    
    private
    # Adds all of the loaded plugins that were missed to Rails.plugins
    def add_loaded_plugins(initializer = self)
      initializer.loaded_plugins.reverse.each do |name|
        path = find_plugin_path(name, initializer)
        Rails.plugins.insert(0, Plugin.new(path)) unless Rails.plugins[name] || path.nil?
      end
    end
    module_function :add_loaded_plugins
    
    # Finds the path of the specified plugin
    def find_plugin_path(name, initializer = self)
      unless PluginAWeek::LoadedPlugins.plugins
        PluginAWeek::LoadedPlugins.plugins = initializer.send(:plugins_to_load).inject({}) do |plugins, path|
          plugins[Plugin.name_for(path)] = path
          plugins
        end
      end
      
      PluginAWeek::LoadedPlugins.plugins[name]
    end
    module_function :find_plugin_path
    
    # Gets a list of all of the plugins that are configured to be loaded
    def plugins_to_load
      if configuration.plugins.nil?
        find_plugins(configuration.plugin_paths).sort
      elsif !configuration.plugins.empty?
        plugin_paths = find_plugins(configuration.plugin_paths)
        configuration.plugins.collect {|name| plugin_paths.find {|path| Plugin.name_for(path) == name}}
      end 
    end
  end
end