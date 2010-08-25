require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::Manufacturer do
  it "returns the full name for a given manufacturer" do
    subaru = Evd::Manufacturer.find(20)

    subaru.name.should == 'Subaru'
  end

  it "has many models" do
    vw = Evd::Manufacturer.find(3)

    expected_model_codes = [304, 1409, 2060]

    returned_model_codes = vw.models.map{|returned_model| returned_model.id}
    expected_model_codes.each {|expected_model| returned_model_codes.should include(expected_model)}
  end
end