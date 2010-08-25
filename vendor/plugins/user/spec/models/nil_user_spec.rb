require File.dirname(__FILE__) + '/../spec_helper'

describe NilUser do
  it "should be singleton" do
    instance = NilUser.instance
    not_singleton_instance = NilUser.new
    not_singleton_instance.should_not be_equal(instance)
    instance2 = NilUser.instance
    instance.should be_equal(instance2)
  end
  
  it "should return true for nil?" do
    NilUser.instance.should be_nil
  end

end