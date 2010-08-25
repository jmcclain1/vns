require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::SquishVin do
  it "has many trims, but ony trims that have different trim descriptions" do
    aSquishVin = Evd::SquishVin.find('1GBJK34686')

    expected_trim_codes = ['USB80CHH544A0', 'USB80CHH544B0']
    returned_trim_codes = aSquishVin.trims.map{|trim| trim.acode}
    
    expected_trim_codes.each{|expected_trim_code| returned_trim_codes.should include(expected_trim_code)}
  end

  it "can squish a full vin" do
    full_vin = '1FDXF47R18E234567'

    Evd::SquishVin.squish(full_vin).should == '1FDXF47R8E'
  end
end