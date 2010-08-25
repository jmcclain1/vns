module Rails
  # Path to the application's lib directory
  mattr_reader :lib_path
  @@lib_path = "#{RAILS_ROOT}/lib"
end