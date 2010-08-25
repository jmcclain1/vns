ENV["RAILS_ENV"] ||= "test"

dir = File.dirname(__FILE__)
embedding_rails_root = "#{dir}/../../../.."

require "rubygems"
require "spec"

require File.expand_path(embedding_rails_root + "/config/environment")

require 'application'
require 'spec/rails'
require 'hpricot'
require 'ruby-debug'

require_package_based_on(dir + "/../lib/rspec_extensions")
require "pivotal_rails_test/mock_flash_hash"
require "pivotal_rails_test/common_test_helper"
require 'pivotal_rails_test/fixture_helper'
require 'rspec_extensions/action_controller_rescue'
require 'rspec_extensions/fixtures_collection'
require 'rspec_extensions/rspec_0_9_4_fixes'
require 'rspec_extensions/spec_helper'
require 'suites/suite_helper'
require 'rspec_extensions/spec_suite_helper'

module Spec::Runner
  class << self
    include FixtureHelper
    def fixture_path
      configuration.fixture_path
    end

    def configure(&blk)
      return unless @configuration.nil?
      yield configuration

      configuration.global_fixtures = all_fixture_symbols
      configuration.include SpecHelper
      configuration.include CommonTestHelper
      configuration.use_transactional_fixtures = true
      configuration.use_instantiated_fixtures  = false
    end
  end
end
