# The following code adds hooks into load/require so that we can override
# which files actually get loaded
class Object #:nodoc:
  # This is very similar to load except that we won't be checking if any new
  # constants were defined
  def load_without_new_constant_marking_with_appable_plugins(file, *extras)
    Dependencies.load_from_plugins(file, :load_without_new_constant_marking) || load_without_new_constant_marking_without_appable_plugins(file, *extras)
  end
  alias_method_chain :load_without_new_constant_marking, :appable_plugins
  
  # Support load
  alias_method :load_without_appable_plugins, :load_without_new_constant_marking_without_appable_plugins
  def load(file, *extras)
    Dependencies.new_constants_in(Object) do
      Dependencies.load_from_plugins(file, :load) || super(file, *extras)
    end
  rescue Exception => exception  # errors from loading file
    exception.blame_file! file
    raise
  end
  
  # Get the original require without constant marking
  def require(file, *extras) #:nodoc:
    super(file, *extras)
  end
  alias_method :require_without_appable_plugins, :require
  
  # Support require
  def require(file, *extras)
    Dependencies.new_constants_in(Object) do
      Dependencies.load_from_plugins(file, :require) || super(file, *extras)
    end
  rescue Exception => exception  # errors from required file
    exception.blame_file! file
    raise
  end
end