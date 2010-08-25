require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class PluginTest < Test::Unit::TestCase
  def test_lib_path
    assert_equal "#{RAILS_ROOT}/lib", Rails.lib_path
  end
end