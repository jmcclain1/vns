require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class AppablePluginsFunctionalTest < Test::Unit::TestCase
  def test_controller_paths
    expected = [
      "#{app_root}/controllers",
      "#{RAILS_ROOT}/components",
      "#{plugins_root}/actor_skeleton/app/controllers",
      "#{plugins_root}/actress_skeleton/app/controllers"
    ]
    
    assert_equal expected, ActionController::Routing.controller_paths
  end
  
  def test_classes_are_reloaded
    require_dependency 'application' unless Object.const_defined?(:ApplicationController)
    assert_equal 'Actress', MovieActressesController.new.pay.name
    
    reset_application!
    
    require_dependency 'application' unless Object.const_defined?(:ApplicationController)
    assert_equal 'Actress', MovieActressesController.new.pay.name
  end
  
  private
  def reset_application!
    ActiveRecord::Base.reset_subclasses
    Dependencies.clear
  end
end