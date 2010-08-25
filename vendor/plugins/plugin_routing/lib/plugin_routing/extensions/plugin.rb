class Plugin
  # The path to the views for this plugin
  def templates_path
    "#{root}/app/views"
  end
  
  # The path to the layout for this plugin
  def layouts_path
    "#{templates_path}/layouts"
  end
  
  # Finds a template with the specified path
  def find_template(template)
    path = "#{templates_path}/#{template}"
    File.exists?(path) ? path : nil
  end
end