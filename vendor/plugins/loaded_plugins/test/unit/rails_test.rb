require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class RailsTest < Test::Unit::TestCase
  def test_plugins
    assert_not_nil Rails.plugins
    assert_instance_of PluginList, Rails.plugins
  end
end