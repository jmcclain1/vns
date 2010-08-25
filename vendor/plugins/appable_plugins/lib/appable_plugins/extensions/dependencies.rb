module Dependencies #:nodoc:
  # Caches where the absolute paths of files that Ruby would load when given
  # a certain path name
  mattr_accessor :load_path_cache
  self.load_path_cache = {}
  
  # Attempts to load the specified file from all of the plugins that are
  # currently loaded.  Use the method to determine how the file is executed
  # (either with :load, :require, or :load_without_new_constant_marking)
  def load_from_plugins(original_file, method = :load)
    file = full_file_path_for(original_file, method)
    
    processed = false
    
    # If the file eixsts, then there's no need to look for it in the load path
    if File.exists?(file)
      file = File.expand_path(file)
      first_file_in_load_path = nil # We don't know this value yet
    
    # Otherwise if the file doesn't exist and the path being loaded is NOT an
    # absolute path, then search for in $LOAD_PATH
    elsif !Pathname.new(file).absolute?
      file = first_file_in_load_path = find_in_load_path(file)
    else
      file = nil
    end
    
    # We can try to load the file from our plugins if:
    # (1) A valid (already expanded) file was found
    # (2) An app path could be matched from the file (see +find_app_path+ for
    # what this constitutes)
    if file && (app_path = find_app_path(file))
      load_paths = find_plugin_load_paths(app_path)
      
      if !load_paths.empty?
        # If we don't already know what the first file is going to be in the
        # load path, then attempt to find it in our main application's app/
        # folder.  This handles loading absolute files from plugin directories
        # when the class also exists in the application's directory
        first_file_in_load_path ||= find_main_app_file(app_path)
        load_paths << first_file_in_load_path if first_file_in_load_path
        load_paths.uniq!
        
        # Load each file, making sure to use the original file that was given
        # to +load+ or +require+ when possible
        load_paths.each do |load_path|
          load_path = original_file if load_path == file
          
          new_result = send("#{method}_without_appable_plugins", load_path)
          processed = true
        end
      end
    end
    
    processed
  end
  
  private
  # Finds the file in the main application's app/ directory that matches the
  # given path.  The path should be in the format of {types}/path/to/file.rb.
  # For example, models/actor.rb or controllers/actor_controller.rb.
  def find_main_app_file(app_path)
    if app_path =~ /^([^\/]+)\/(.+)$/ && main_app_path = find_main_app_directories($1).find {|path| File.exists?(File.join(path, $2))}
      File.expand_path(File.join(main_app_path, $2))
    end
  end
  
  # Finds all app/ paths in $LOAD_PATH for the given type.  By default, it
  # will find all app/ paths, including models, controllers, and helpers.
  def find_main_app_directories(type = '.+')
    # Make sure we only get unique paths since Rails likes to put in directories
    # with both a trailing slash and no trailing slash
    unique_load_path = $LOAD_PATH.collect {|path| path.ends_with?('/') ? path.chop : path}.uniq
    unique_load_path.find_all {|path| path =~ /^#{File.join(RAILS_ROOT, 'app', type)}/}
  end
  
  # Gets all plugin paths that match the specified app path
  def find_plugin_load_paths(app_path)
    load_paths = Rails.plugins.inject([]) do |load_paths, plugin|
      plugin_file = plugin.find_file(app_path)
      load_paths << File.expand_path(plugin_file) if plugin_file
      load_paths
    end
  end
  
  # Gets the app path for the file, such as models/foo.rb or controllers/bar.rb.
  # If the specific type is not supported (i.e. enabled through
  # +Dependencies.mixable_app_types+), then nil will be returned
  def find_app_path(file)
    app_path = nil
    
    if load_path = find_load_path_for(file)
      Plugin.mixable_app_types.each do |type, regex|
        file_path = file.sub(load_path, '')
        
        # Make sure it matches our regular expression if there are certain file
        # name conventions
        if file =~ /app\/#{type}\/(.*\/)?(#{regex.source})(\.rb)?$/
          app_path = File.join(type.to_s, file_path)
          break
        end
      end
    end
    
    app_path
  end
  
  # Finds what load path would have been used for the given file path
  def find_load_path_for(load_file)
    matched_paths = $LOAD_PATH.find_all {|load_path| load_file.include?(File.expand_path(load_path))}
    load_path = matched_paths.max {|a, b| a.length <=> b.length}
    File.expand_path(load_path) if load_path
  end
  
  # Finds the file that Ruby would load if we tried to search for in the load
  # path.
  def find_in_load_path(file)
    # Load it from our cache whenever we can
    unless load_file = load_path_cache[file]
      # Find the first path that matches /app/ and contains the given file
      if load_path = $LOAD_PATH.find {|load_path| File.exists?(File.join(load_path, file))}
        load_file = File.expand_path(File.join(load_path, file))
      end
      
      load_path_cache[file] = load_file if load_file
    end
    
    load_file
  end
  
  # Gets the full file path with .rb appended
  def full_file_path_for(file, method)
    if !use_strict_file_names?(method) && !file.ends_with?('.rb')
      "#{file}.rb"
    else
      file
    end
  end
  
  # +require+ doesn't care what extension was specified, while +load+ requires
  # the exact extension
  def use_strict_file_names?(method) #:nodoc:
    method != :require
  end
end