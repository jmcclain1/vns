# Load the environment
ENV['RAILS_ENV'] ||= 'in_memory'
require File.dirname(__FILE__) + '/rails_root/config/environment.rb'

# Load the testing framework
require 'test/unit'
require 'active_record/fixtures'

class Test::Unit::TestCase
  def initialize_schema_information
    ActiveRecord::Base.connection.initialize_schema_information
  end
end