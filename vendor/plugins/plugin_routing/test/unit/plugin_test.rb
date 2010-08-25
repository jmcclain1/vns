require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PluginTest < Test::Unit::TestCase
  def setup
    @controller_skeleton_app_root = "#{RAILS_ROOT}/vendor/plugins/controller_skeleton/app"
    @plugin = Rails.plugins[:controller_skeleton]
  end
  
  def test_templates_path
    assert_equal "#{@controller_skeleton_app_root}/views", @plugin.templates_path
  end
  
  def test_layouts_path
    assert_equal "#{@controller_skeleton_app_root}/views/layouts", @plugin.layouts_path
  end
  
  def test_find_template_exists
    assert_equal "#{@controller_skeleton_app_root}/views/plugin_with_app_layout/index.rhtml", @plugin.find_template('plugin_with_app_layout/index.rhtml')
  end
  
  def test_find_template_nonexistent
    assert_nil @plugin.find_template('plugin_with_app_layout/invalid.rhtml')
  end
end