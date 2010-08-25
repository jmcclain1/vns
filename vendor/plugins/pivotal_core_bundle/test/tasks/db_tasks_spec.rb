dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe DbTasks, "::ENVIRONMENTS" do
  it "defaults to development and test" do
    DbTasks::ENVIRONMENTS.length.should == 2
    DbTasks::ENVIRONMENTS.should include('development')
    DbTasks::ENVIRONMENTS.should include('test')
  end
end

describe DbTasks, "#init" do
  before do
    DbTasks::ENVIRONMENTS.push("test_suite")
  end

  after do
    DbTasks::ENVIRONMENTS.pop
  end

  # TODO: Make better specs. This is here get some specs started.
  it "inits the database for the environments in ENVIRONMENTS" do
    tasks = DbTasks.new(nil)
    tasks.should_receive(:init_with_environment).with('development')
    tasks.should_receive(:init_with_environment).with('test')
    tasks.should_receive(:init_with_environment).with('test_suite')

    tasks.init
  end
end
