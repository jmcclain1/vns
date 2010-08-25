class Plugin
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
        
        # Sort for consistency across platforms
        @load_paths.concat(Dir["#{app_path}/*/"].map(&:chop).sort!)
      end
    end
    
    @load_paths
  end
  
  def load_with_appable_plugins
    load_without_appable_plugins
    inject_controller_paths
  end
  alias_method_chain :load, :appable_plugins
  
  # Injects the plugin's app paths for use in the Rails Dependencies mechanism.
  # It will modify the following attributes:
  # * +$LOAD_PATH+
  # * +Dependencies.load_paths+
  # * +Dependencies.load_once_paths+
  # * +Dependencies.mixable_app_types+
  # * +ActionController::Routing.controller_paths+
  def inject_dependencies
    add_to_load_path
    add_to_dependency_load_paths
    add_to_dependency_load_once_paths
    add_to_mixable_app_types
  end
  
  # Injects the controllers path if one exists
  def inject_controller_paths
    ActionController::Routing.controller_paths << controllers_path if File.exists?(controllers_path)
  end
  
  def find_file(file)
    if enable_code_mixing?
      file = "#{app_path}/#{file}"
      file if File.exists?(file)
    end
  end
  
  private
  # Adds the paths to $LOAD_PATH
  def add_to_load_path #:nodoc:
    $LOAD_PATH.insert($LOAD_PATH.index("#{RAILS_ROOT}/lib") + 1, *load_paths)
  end
  
  # Adds the paths to Dependencies.load_paths
  def add_to_dependency_load_paths #:nodoc:
    Dependencies.load_paths.concat(load_paths)
  end
  
  # Adds the paths to Dependencies.load_once_paths to ensure that they are
  # not reloaded in development
  def add_to_dependency_load_once_paths #:nodoc:
    Dependencies.load_once_paths.concat(load_paths)
  end
  
  # Adds the app types that can be mixed to Dependencies.mixable_app_types
  def add_to_mixable_app_types #:nodoc:
    paths = load_paths.collect {|path| File.expand_path(path)}
    paths.each do |path|
      if path =~ /app\/([^\/]+)(\/.*)?$/
        type = $1.to_sym
        Dependencies.mixable_app_types[type] ||= /.+/
      end
    end
  end
end