class Plugin
  # Track what application types should be automatically mixed in.  This maps
  # the type to a regular expression describing how the file name will be
  # matched.  If a type is removed, it will not be matched by any plugins.
  cattr_accessor :mixable_app_types
  self.mixable_app_types = {
    :controllers => /.+_controller|application/,
    :helpers => /.+_helper/,
    :apis => /.+_api/,
    :services => /.+_service/,
    :models => /.+/
  }
  
  attr_accessor :enable_code_mixing
  
  # True to enable models/controllers/helpers/etc. to be automatically mixed in
  # through this plugin
  def enable_code_mixing
    @enable_code_mixing.nil? ? true : @enable_code_mixing
  end
  alias_method :enable_code_mixing?, :enable_code_mixing
  
  # The path to the root app directory
  def app_path
    "#{root}/app"
  end
  
  # The path to the controllers directory
  def controllers_path
    "#{app_path}/controllers"
  end
  
  # Gets a list of all of the additional load paths that should be added to the
  # environment (excluding the lib path)
  def load_paths
    unless @load_paths
      @load_paths = []
      
      if File.directory?(app_path)
        @load_paths << app_path
        
        # Sort for consistency
        self.class.mixable_app_types.keys.map(&:to_s).sort.each do |type|
          path = "#{app_path}/#{type}"
          @load_paths << path if File.directory?(path)
        end
      end
    end
    
    @load_paths
  end
  
  # Injects the plugin's dependencies
  def before_load_with_appable_plugins
    inject_dependencies
  end
  alias_method_chain :before_load, :appable_plugins
  
  # When the plugin's dependencies are injected, the lib path is also included
  # in $LOAD_PATH in order to preserve the order of the plugin's paths.  As a
  # result, when Rails loads the plugin, the lib path will now exist twice in
  # $LOAD_PATH.  Rather than intruding on the Rails core, we work around this by
  # just removing the extra lib path that was added
  def after_load_with_appable_plugins
#    $LOAD_PATH.delete_at($LOAD_PATH.index(lib_path)) if lib_path? && @dependencies_injected
  end
  alias_method_chain :after_load, :appable_plugins
  
  # Injects the plugin's controller paths and dependencies
  def after_initialize_with_appable_plugins
    after_initialize_without_appable_plugins
    inject_controller_paths
    
    # Inject dependencies when being loaded after initialization in case
    # loaded_plugins was loaded as a gem midway through application initialization
    inject_dependencies(:after_initialize)
  end
  alias_method_chain :after_initialize, :appable_plugins
  
  # Injects the plugin's app paths for use in the Rails Dependencies mechanism.
  # It will modify the following attributes:
  # * +$LOAD_PATH+
  # * +Dependencies.load_paths+
  # * +Dependencies.load_once_paths+
  # * +ActionController::Routing.controller_paths+
  def inject_dependencies(event = :before_load)
    return if @dependencies_injected
    @dependencies_injected = true
    
    unless load_paths.empty?
      add_to_load_path(event)
      add_to_dependency_load_paths(event)
    end
  end
  
  # Looks for the specified file within this plugin's app path.  The expected
  # format of the file is {type}/path/to/file.  For example,
  #   models/foo.rb
  #   controllers/foo/bar.rb
  #   apis/foo_api.rb
  # 
  # If no file can be found or code mixing is disabled, nil will be returned
  def find_file(file)
    if enable_code_mixing?
      file = "#{app_path}/#{file}"
      file if File.exists?(file)
    end
  end
  
  private
  # Injects the controllers path if one exists
  def inject_controller_paths
    ActionController::Routing.controller_paths << controllers_path if File.exists?(controllers_path)
  end
  
  # Adds the paths to $LOAD_PATH
  def add_to_load_path(event) #:nodoc:
    paths = load_paths
    
    # If the load path already includes this plugin's lib path, then this plugin
    # has already been loaded (via the Rails::Initializer), so we can figure out
    # where the app paths are going
    if $LOAD_PATH.include?(lib_path)
      index = $LOAD_PATH.index(lib_path)
    
    # If we couldn't find a load path, but this isn't the last plugin that was
    # loaded, then it means that this plugin has already been loaded (via the
    # Rails::Initializer) and doesn't have a lib path.  
    elsif event == :after_initialize
      plugins_after_paths = plugins_after.map(&:root)
      nearest_load_path = $LOAD_PATH.reverse.find {|path| plugins_after_paths.detect {|plugin_path| path.include?(plugin_path)}}
      
      index = ($LOAD_PATH.index(nearest_load_path || Rails.lib_path) || 0) + 1
    else
      index = ($LOAD_PATH.index(Rails.lib_path) || 0) + 1
      paths += [lib_path] if lib_path?
    end
    
    $LOAD_PATH.insert(index, *paths)
  end
  
  # Adds the paths to Dependencies.load_paths
  def add_to_dependency_load_paths(event) #:nodoc:
    if index = Dependencies.load_paths.index(lib_path)
      Dependencies.load_paths.insert(index, *load_paths)
    elsif event == :after_initialize
      plugins_before_paths = plugins_before.map(&:root)
      plugin_before_load_paths = Dependencies.load_paths.find_all {|path| plugins_before_paths.detect {|plugin_path| path.include?(plugin_path)}}
      index = (Dependencies.load_paths.index(plugin_before_load_paths.last) || -1) + 1
      
      Dependencies.load_paths.insert(index, *load_paths)
    else
      Dependencies.load_paths.concat(load_paths)
    end
  end
end
