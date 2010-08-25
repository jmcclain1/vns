require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::TrimColor do
  it "can parse the color for red, green, blue" do
    aColor = Evd::TrimColor.find('USB80CHT279A00112U')

    aColor.r_code.should == 70
    aColor.g_code.should == 23
    aColor.b_code.should == 36
  end

  it "can parse the color for its generic name" do
    aColor = Evd::TrimColor.find('USB80CHT279A00166U')

    aColor.generic_name.should == 'Red'
  end

  it "can parse the color for interior vs exterior color" do
    aExteriorColor = Evd::TrimColor.find('USB80CHT304A00312U')
    aInteriorColor = Evd::TrimColor.find('USB80CHT27AA001193')

    aExteriorColor.exterior?.should == true
    aInteriorColor.exterior?.should == false
  end

  it "returns a properly formatted name for the color" do
    aExteriorColor = Evd::TrimColor.find('USB80CHT279A00112U')
    aInteriorColor = Evd::TrimColor.find('USB80CHT27AA001193')

    aExteriorColor.name.should == 'Dark Cherry Metallic'
    aInteriorColor.name.should == 'Ebony w/Custom Leather-Appointed Seat Trim'
  end
end