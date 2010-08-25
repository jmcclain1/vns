# The PluginList class is an array, enhanced to allow access to loaded plugins
# by name, and iteration over loaded plugins in order of priority.
#
# Each loaded plugin has a corresponding Plugin instance within this array, and 
# the order the plugins were loaded is reflected in the entries in this array.
#
# For more information, see the Rails module.
class PluginList < Array
  # Finds plugins with the given name (accepts Strings or Symbols), or index.
  # So, Rails.plugins[0] returns the first-loaded Plugin, and Rails.plugins[:foo]
  # returns the Plugin instance for the foo plugin itself.
  def [](name)
    if name.is_a?(String) || name.is_a?(Symbol)
      self.find {|plugin| plugin.name.to_s == name.to_s}
    else
      super
    end
  end
  
  # Gets the plugins in the specified comma-delimited list.  If the list is
  # not specified (i.e. nil), then all plugins are returned
  def find_by_names(names = nil)
    if names
      plugins = names.split(',')
      missing_plugins = plugins - map(&:name)
      
      raise "Couldn't find plugin(s): #{missing_plugins.to_sentence}" if missing_plugins.any?
      plugins.collect! {|name| self[name]}
    else
      plugins = self
    end
    
    plugins
  end
  
  # Go through each plugin, highest priority first (last loaded first). Effectively,
  # this is like <tt>Rails.plugins.reverse</tt>, except when given a block, when it behaves
  # like <tt>Rails.plugins.reverse.each</tt>.
  def by_precedence(&block)
    if block_given?
      reverse.each { |x| yield x }
    else 
      reverse
    end
  end
end