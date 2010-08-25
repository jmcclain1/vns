dir = File.dirname(__FILE__)
require "#{dir}/../../pivotal_core_bundle/lib/spec_framework_bootstrap"
require File.expand_path(dir + "/../../user/test/test_case_methods")
Spec::Runner.configure do |config|
  dir = File.dirname(__FILE__)
  config.fixture_path = "#{dir}/../test/fixtures"
  config.before(:each) do
    ActionMailer::Base.deliveries = []
  end
  include UserPluginTestCaseMethods
  config.prepend_before do
    class << ActionController::Flash::FlashHash
      def new
        MockFlashHash.new
      end
    end
  end
end