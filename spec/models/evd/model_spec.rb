require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::TrimColor do
  it "returns its name" do
    new_beetle = Evd::Model.find(306)

    new_beetle.name.should == 'New Beetle'
  end

  it "belongs to a make" do
    new_beetle = Evd::Model.find(306)
    vw_make = Evd::Make.find('VW')

    new_beetle.make.should == vw_make
  end

  it "belongs to a manufacturer" do
    new_beetle = Evd::Model.find(306)
    vw_manufacturer = Evd::Manufacturer.find(3)

    new_beetle.manufacturer.should == vw_manufacturer
  end

  it "has many trims" do
    new_beetle = Evd::Model.find(306)

    expected_trim_codes = [
     'USB80VWC051A0',
     'USB80VWC051B0',
     'USB80VWC052B1'
    ]

    returned_trim_codes = new_beetle.trims.map{|trim| trim.acode}
    expected_trim_codes.each {|trim_code| returned_trim_codes.should include(trim_code)}
  end
end