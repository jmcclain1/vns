module Rails
  # A list of all the plugins that have been loaded so far, in the order which
  # they were *completely* loaded
  mattr_accessor :plugins
  self.plugins = PluginList.new
end