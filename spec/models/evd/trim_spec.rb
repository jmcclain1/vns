require File.dirname(__FILE__) + '/../../spec_helper'

describe Evd::Trim do
  it "has many available features" do
    aTrim = Evd::Trim.find('USB80FOC052B0')

    expected_features = ['USB80FOC052B003918', 'USB80FOC052B00197P', 'USB80FOC052B001941']

    returned_features = aTrim.available_features.map{|feature| feature.id}
    expected_features.each {|expected_feature| returned_features.should include(expected_feature)}
  end

  it "has many colors" do
    aTrim = Evd::Trim.find("USB80CHT308A0")

    expected_exterior_color_codes = [
     'TYPE=Primary RED=70 GREEN=23 BLUE=36 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Red GENERICCLRCODE=13',
     'TYPE=Primary RED=92 GREEN=91 BLUE=90 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Gray GENERICCLRCODE=5',
     # 'TYPE=Primary RED=15 GREEN=15 BLUE=26 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Dk. Blue GENERICCLRCODE=26',
    ]

    expected_interior_color_codes = [
     'TYPE=Interior RED=35 GREEN=34 BLUE=33 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Black GENERICCLRCODE=2',
     'TYPE=Interior RED=35 GREEN=34 BLUE=33 TABLEREQ=TGK-01 TABLE=Secondary w/1LT & SEO Paints GENERICCLR=Black GENERICCLRCODE=2',
     'TYPE=Interior RED=35 GREEN=34 BLUE=33 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Black GENERICCLRCODE=2',
     'TYPE=Interior RED=35 GREEN=34 BLUE=33 TABLEREQ=TGK-01 TABLE=Secondary w/1LT & SEO Paints GENERICCLR=Black GENERICCLRCODE=2',
     'TYPE=Interior RED=152 GREEN=142 BLUE=117 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Beige GENERICCLRCODE=31',
     'TYPE=Interior RED=152 GREEN=142 BLUE=117 TABLEREQ=TGK-01 TABLE=Secondary w/1LT & SEO Paints GENERICCLR=Beige GENERICCLRCODE=31',
     'TYPE=Interior RED=152 GREEN=142 BLUE=117 TABLEREQ=ZY1-01 TABLE=Primary w/1LT GENERICCLR=Beige GENERICCLRCODE=31',
    ]

    returned_interior_color_codes = aTrim.interior_colors.map{|color| color.rgb}
    expected_interior_color_codes.each {|color_code| returned_interior_color_codes.should include(color_code)}

    returned_exterior_color_codes = aTrim.exterior_colors.map{|color| color.rgb}
    expected_exterior_color_codes.each {|color_code| returned_exterior_color_codes.should include(color_code)}    
  end

  it "is has many squish vins" do
    aTrim = Evd::Trim.find('USB80FOC052B0')

    expected_squish_vins = ['1ZVFT84N85', '1ZVHT84N85']

    returned_squish_vins = aTrim.squish_vins.map{|sv| sv.squish_vin}
    expected_squish_vins.each {|expected_sv| returned_squish_vins.should include(expected_sv)}
  end

  it "belongs to a model" do
    aTrim = Evd::Trim.find('USB80FOC052B0')

    aTrim.model.should == Evd::Model.find(97)
  end

  it "can return its year in YYYY format" do
    aTrim = Evd::Trim.find('USB80FOC052B0')

    aTrim.year.should == 2008

    aTrim.yearcode = 'A51'
    aTrim.year.should == 1995
  end

  it "can return all trims for a given VIN" do
    expected_trim_codes = ['USB80CHC191A0', 'USB80CHC191B0']

    returned_trim_codes = Evd::Trim.find_all_by_vin('KL1TD66618B234567').map{|trim| trim.acode}

    expected_trim_codes.each {|expected_trim_code| returned_trim_codes.should include(expected_trim_code)}    
  end

  it "has a characterization based on year, trim name, make, and model name" do
    aTrim = Evd::Trim.find('USB80FOC052B0')

    aTrim.characterization.should == '2008 Ford Mustang V6 Premium'
  end
end