module RoutesFromPlugin
  module MapperExtension
    include PluginUtils

    # Loads the set of routes from within a plugin and evaluates them at this
    # point within an application's main <tt>routes.rb</tt> file.
    #
    # Plugin routes are loaded from <tt><plugin_root>/routes.rb</tt>.
    def routes_from_plugin(name)
      name = name.to_s
      routes_path = File.join(path_for_plugin(name), "config/routes.rb")
      RAILS_DEFAULT_LOGGER.debug "Loading routes from #{routes_path}."
      eval(IO.read(routes_path), binding, routes_path) if File.file?(routes_path)
    end
  end
end