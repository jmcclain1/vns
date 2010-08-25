module Kernel
  # We replace Ruby's require with our own, which is capable of loading plugins
  # on demand.
  #
  # When you call <tt>require 'x'</tt>, this is what happens:
  # * If the file can be loaded from the existing Ruby loadpath, it is.
  # * Otherwise, installed plugins (both in the application and as gems) are
  #   searched for a name that matches.  If it's found, that plugin is loaded
  #   (added to the load path).
  # 
  # The normal <tt>require</tt> functionality of returning false if
  # that file has already been loaded is preserved.
  def gem_original_require_with_plugins(name)
    gem_original_require_without_plugins(name)
  rescue LoadError => load_error
    if PluginAWeek::PluginDependencies.initializer
      begin
        plugin(name, true)
      rescue LoadError => plugin_load_error
        if plugin_load_error.message.include?("No such plugin: #{name}")
          raise load_error
        else
          raise
        end
      end
    else
      raise
    end
  end
  alias_method_chain :gem_original_require, :plugins
  
  # Searches for a plugin with the specified name.  This will <tt>not</tt> use
  # Ruby's require.  If the plugin cannot be found, a MissingSourceFile error
  # will be raising indicating that the plugin is missing.  Otherwise, it will
  # return true.
  def plugin(name, strict_search = false)
    initializer = PluginAWeek::PluginDependencies.initializer
    raise PluginAWeek::PluginDependencies::InitializerNotLoaded.new('Rails has not be initialized yet') unless initializer
    
    if plugin = initializer.send(:find_plugin, name, :strict => strict_search)
      initializer.send(:load_plugin, plugin)
    else
      raise MissingSourceFile.new("No such plugin: #{name}", name)
    end
  end
  alias_method :require_plugin, :plugin
end