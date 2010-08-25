require File.dirname(__FILE__) + '/../spec_helper'

describe FieldMap do

  before do
    @foo = Field.new(:foo, "Foo", :text_box)
    @bar = Field.new(:bar, "Bar", :text_box)
    @baz = Field.new(:baz, "Baz", :text_box)
  end
  
  it "adds fields to itself indexed by name" do
    map = FieldMap.new
    map.add(@foo)
    map.add(@bar)
    map[:foo].should == @foo
    map[:bar].should == @bar
  end

  it "adds fields in the constructor" do
    map = FieldMap.new(@foo, @bar)
    map[:foo].should == @foo
    map[:bar].should == @bar
  end

  it "retrieves some fields by name, in the order passed" do
    map = FieldMap.new(@foo, @bar, @baz)
    map.some(:baz, :foo).should == [@baz, @foo]
  end
end