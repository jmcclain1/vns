dir = File.dirname(__FILE__)
require 'rubygems'
require 'spec'
require "#{dir}/../lib/markaby"
require "#{dir}/../lib/markaby/rails"

describe MarkabyHelper do
  include MarkabyHelper
  
  predicate_matchers[:a] = :is_a?
  
  before do
    self.stub!(:assigns).and_return({})
  end
  
  it "when asked to render markaby from an Markaby builder, sends messages from the block to its caller" do

    markaby_builder = Markaby::Rails::Builder.new({}, self)
    
    push_method = markaby_builder_stack.method(:push)
    markaby_builder_stack.should_receive(:push).with(markaby_builder).ordered.and_return(&push_method)

    pop_method = markaby_builder_stack.method(:pop)
    markaby_builder_stack.should_receive(:pop).ordered.and_return(&pop_method)
    
    markaby_builder.instance_eval do
      markaby do
        self << "testing 123"
      end
    end    
  end

  it "when asked for a fresh markaby from within a call to markaby, returns a string" do
    fresh_result = nil
    unfresh_result = markaby do
      text "unfresh stuff"
      fresh_result = helpers.fresh_markaby do
        text "fresh stuff"
      end
    end
    unfresh_result.should == "unfresh stuff"
    fresh_result.should == "fresh stuff"
  end
end