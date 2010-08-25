# These lines must be at the top of each plugin's test_helper
dir = File.dirname(__FILE__)
require "#{dir}/../../pivotal_core_bundle/lib/test_framework_bootstrap"
Test::Unit::TestCase.fixture_path =  File.expand_path(dir + "/fixtures")

require "#{dir}/test_case_methods"

# Plugin-specific test helper code below
class ApplicationController
  public :logged_in_user, :logged_in_user=, :logged_in?
end

require 'users_controller'

class UserPluginTestCase < Pivotal::FrameworkPluginTestCase
  include FlexMock::TestCase
  include UserPluginTestCaseMethods
  
  fixtures :users,
           :user_activities,
           :tokens,
           :profiles,
           :profile_answers,
           :profile_questions,
           :profile_question_categories,
           :assets, 
           :assets_associations,
           :asset_versions
end