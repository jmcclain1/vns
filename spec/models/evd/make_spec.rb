require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::Make do
  it "returns the full name for a given make" do
    aMake = Evd::Make.find('FO')

    aMake.name.should == 'Ford'
  end

  it "has many models" do
    vw = Evd::Make.find("VW")

    expected_model_codes = [304, 1409, 2060]

    returned_model_codes = vw.models.map{|returned_model| returned_model.id}
    expected_model_codes.each {|expected_model| returned_model_codes.should include(expected_model)}
  end

end

describe Evd::Make, "#all" do
  it "returns a list of models in alphabetical order" do
    makes = Evd::Make.all
    makes.size.should > 0
    previous = nil
    makes.each do |make|
      (previous.name.downcase <=> make.name.downcase).should < 0 if previous
      previous = make
    end
  end
end
