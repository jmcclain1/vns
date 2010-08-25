dir = File.dirname(__FILE__)

# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"

require File.expand_path(dir + "/../../../../vendor/plugins/pivotal_core_bundle/lib/spec_framework_bootstrap")

# Even if you're using RSpec, RSpec on Rails is reusing some of the
# Rails-specific extensions for fixtures and stubbed requests, response
# and other things (via RSpec's inherit mechanism). These extensions are 
# tightly coupled to Test::Unit in Rails, which is why you're seeing it here.
Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  dir = File.dirname(__FILE__)
  config.fixture_path = "#{dir}/fixtures"
end

def eval_context_eval(&block)
  Spec::Rails::Runner::EvalContext.class_eval(&block)
end

class Cat < ActiveRecord::Base
  include Locatable
  set_table_name :cats
  def <=>(other)
    name <=> other.name
  end
  def to_s
    "Cat:#{name} in location #{location.latitude}, #{location.longitude}"
  end
end

class Dog < ActiveRecord::Base
  include Locatable
  set_table_name :dogs
  def <=>(other)
    name <=> other.name
  end
  def to_s
    "Dog:#{name} in location #{location.latitude}, #{location.longitude}"
  end
end

module GeolocationFixtures
  def self.included(base)
    base.set_fixture_class :locations => "Location", :location_caches => "LocationCache",
       :cats => "Cat",
       :dogs => "Dog"
    base.fixtures :locations, :cats, :dogs, :location_caches
  end
end