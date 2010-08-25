# An instance of Plugin is created for each plugin loaded by Rails, and
# stored in the <tt>Rails.plugins</tt> PluginList
class Plugin
  # The name of this plugin
  attr_accessor :name

  # The directory in which this plugin is located
  attr_accessor :root
  
  class << self
    # Gets the name of the plugin, given the path to it.  The following would
    # return plugin_xyz:
    # * plugin_xyz
    # * plugin_xyz-1.2
    # * plugin_xyz-1.2.0
    # * plugin_xyz-1.2.0-win32
    def name_for(path)
      name = File.basename(path)
      /^(.+)-#{Gem::Version::NUM_RE}(-.+)?$/.match(name) && $1 || name
    end
  end
  
  def initialize(root) #:nodoc:
    root.chop! if root.ends_with?('/')
    
    @root = root
    @name = self.class.name_for(root)
  end
  
  # The path to the plugin's lib folder
  def lib_path
    "#{root}/lib"
  end
  
  # Does the plugin's lib path exist?
  def lib_path?
    File.exists?(lib_path)
  end
  
  # Gets all of the plugins that were loaded before this one
  def plugins_before
    if Rails.plugins.first == self
      []
    else
      Rails.plugins[0..Rails.plugins.index(self)-1]
    end
  end
  
  # Gets all of the plugins that were loaded after this one
  def plugins_after
    if Rails.plugins.last == self
      []
    else
      Rails.plugins[Rails.plugins.index(self)+1..Rails.plugins.length-1]
    end
  end
  
  # Invoked immediately before Rails::Initializer loads the plugin
  def before_load
  end
  
  # Invoked immediately after Rails::Initializer loads the plugin
  def after_load
  end
  
  # Invoked during the after_initialize Rails::Initializer callback
  def after_initialize
  end
  
  def ==(other_obj) #:nodoc:
    if other_obj.is_a?(Plugin)
      other_obj.name == name
    else
      other_obj.to_s == name
    end
  end
end