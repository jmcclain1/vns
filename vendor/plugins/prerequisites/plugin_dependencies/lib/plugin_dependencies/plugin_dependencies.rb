module PluginAWeek #:nodoc:
  module PluginDependencies #:nodoc:
    mattr_accessor :initializer
    
    def self.included(base) #:nodoc:
      base.class_eval do
        alias_method_chain :initialize, :plugin_dependencies
        alias_method_chain :find_plugins, :plugin_dependencies
        alias_method_chain :load_plugins, :plugin_dependencies
        alias_method_chain :load_plugin, :plugin_dependencies
      end
    end
    
    def self.extended(initializer) #:nodoc:
      self.initializer = initializer
    end
    
    # The initializer was never loaded
    class InitializerNotLoaded < Exception #:nodoc:
    end
    
    def initialize_with_plugin_dependencies(configuration)
      PluginAWeek::PluginDependencies.initializer = self
      initialize_without_plugin_dependencies(configuration)
    end
    
    # Adds support for checking the names of plugins that are gem-based names
    def load_plugins_with_plugin_dependencies
      if configuration.plugins.nil?
        load_plugins_without_plugin_dependencies
      elsif !configuration.plugins.empty?
        plugin_paths = find_plugins(configuration.plugin_paths)
        configuration.plugins.each do |name|
          name = name.to_a.first
          path = plugin_paths.find {|p| plugin_name(p) == name}
          raise(LoadError, "Cannot find the plugin '#{name}'!") if path.nil?
          load_plugin path
        end
        
        $LOAD_PATH.uniq!
      end
    end
    
    protected
    # Loads the plugin along with any tasks associated with that plugin
    def load_plugin_with_plugin_dependencies(directory)
      success = load_plugin_without_plugin_dependencies(directory)
#      Dir[File.join("#{directory}", 'tasks/**/*.rake')].sort.each {|ext| load ext} if defined?(Rake)
      
      success
    end
    
    # Finds all the plugins to load in the application.  This also includes the
    # paths of any plugin gems specified in +configuration.plugins+.
    def find_plugins_with_plugin_dependencies(*base_paths)
      # Make sure we don't add the gems more than once, since find_plugins is a
      # recursive method
      if @finding_plugins
        find_plugins_without_plugin_dependencies(*base_paths)
      else
        @finding_plugins = true
        plugins = find_plugins_without_plugin_dependencies(*base_paths)
        @finding_plugins = nil
        
        if configuration.plugins && !configuration.plugins.empty?
          found_plugins = plugins.collect {|plugin| File.basename(plugin)}
          configuration.plugins.each do |plugin|
            name, version = plugin.to_a
            next if found_plugins.include?(name)
            
            plugin = find_plugin_in_gems(name, :version => version)
            plugins << plugin if plugin
          end
        end
        
        plugins
      end
    end
    
    # Gets the name of the plugin, given the path to it.  The following would
    # return plugin_xyz:
    # * plugin_xyz
    # * plugin_xyz-1.2
    # * plugin_xyz-1.2.0
    # * plugin_xyz-1.2.0-win32
    def plugin_name(path)
      name = File.basename(path)
      /^(.+)-#{Gem::Version::NUM_RE}(-.+)?$/.match(name) && $1 || name
    end
    
    # Finds the plugin with the specified name, searching in the following
    # locations:
    # * Application plugin paths (such as /vendor/plugins)
    # * Gem paths
    # 
    # Application plugins will always override gem plugins
    def find_plugin(name, *args)
      find_plugin_in_application(name) || find_plugin_in_gems(name, *args)
    end
    
    # Finds a plugin with the given name, installed in the application's plugins
    # path (e.g. vendor/plugins)
    def find_plugin_in_application(name)
      find_plugins_without_plugin_dependencies(configuration.plugin_paths).find {|path| path =~ /\/#{name}$/}
    end
    
    # Finds a plugin with the given name, installed as a gem
    def find_plugin_in_gems(name, options = {})
      options.assert_valid_keys(:version, :strict)
      options.reverse_merge!(
        :strict => false
      )
      
      gem = Gem::Dependency.new(name, options[:version] || [])
      spec = Gem.source_index.find_name(gem.name, gem.version_requirements).last
      spec.full_gem_path if spec && (!options[:strict] || File.exists?("#{spec.full_gem_path}/init.rb"))
    end
  end
end