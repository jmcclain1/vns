require File.dirname(__FILE__) + '/../spec_helper'
require "#{RAILS_ROOT}/lib/ed_importer"

describe EdImporter do
  before :all do
    db_file = "#{RAILS_ROOT}/db/imported_auto_data.sql"
    db_username = 'pivotal'
    db_password = 'password'
    db_name = 'vns_test'
    system("mysql -u #{db_username} -p#{db_password} #{db_name} < #{db_file}")
  end

  it "can import all styles" do
    Style.count.should == 1143
  end

  it "can verify the style parameters for ad_style_id 100274259" do
    expect_style(Style.find_by_ad_style_id(100274259),
        :drive       => '4WD',
        :doors       => 4,
        :body        => '4dr SUV',
        :description => '4 Dr Z71 4WD SUV',
        :trim        => 'Z71')
  end

  it "can verify the style parameters for ad_style_id 100624494" do
    expect_style(Style.find_by_ad_style_id(100624494),
        :drive       => 'RWD',
        :doors       => 3,
        :body        => 'Cargo Van',
        :description => '2500 3dr Ext Van',
        :trim        => '2500')
  end

  it "can verify the style parameters for ad_style_id 100547864" do
    expect_style(Style.find_by_ad_style_id(100547864),
        :drive       => 'FWD',
        :doors       => 4,
        :body        => 'Sedan',
        :description => 'LS 4dr Sedan',
        :trim        => 'LS')
  end

  def expect_style(style, options)
    style.drive.should == options[:drive]
    style.doors.should == options[:doors]
    style.body.should == options[:body]
    style.description.should == options[:description]
    style.trim.should == options[:trim]
  end

  it "can import all models and makes" do
    Model.count.should == 146
    Make.count.should  == 2
  end

  it "can verify the model parameters for ad_model_id 3861" do
    expect_model(Model.find_by_ad_model_id(3861),
        :year        => 2002,
        :make        => "Chevrolet",
        :name        => 'Astro')
  end

  it "can verify the model parameters for ad_model_id 100502680" do
    expect_model(Model.find_by_ad_model_id(100502680),
        :year        => 2004,
        :make        => "Volkswagen",
        :name        => "Phaeton")
  end

  it "can verify the model parameters for ad_model_id 100505104" do
    expect_model(Model.find_by_ad_model_id(100505104),
        :year        => 2005,
        :make        => "Volkswagen",
        :name        => "Touareg")
  end

  def expect_model(model,options)
      model.year.should == options[:year]
      model.make.name.should == options[:make]
      model.name.should == options[:name]
  end

  it "can import all engines and verify engine names are trimmed" do
    Engine.count.should == 50

    Engine.find(:all).each do |e|
      e.name.strip.should == e.name
    end
  end

  it "can verify the engine parameters for the '6.5L Turbocharged Diesel V8 OHV 16V FI Engine'" do
    expect_engine(Engine.find_by_name('6.5L Turbocharged Diesel V8 OHV 16V FI Engine'),
        :cylinders     => 8,
        :configuration => 'V',
        :aspiration    => 'TC',
        :fuel          => 'D',
        :displacement  => "6.5")
  end

  it "can verify the engine parameters for the 'Engine Immobilizer'" do
    expect_engine(Engine.find_by_name('Engine Immobilizer'),
        :cylinders     => nil,
        :configuration => nil,
        :aspiration    => nil,
        :fuel          => nil,
        :displacement  => nil)
  end

  it "can verify the engine parameters for the '2.2L CNG I4 DOHC 16V FI Engine'" do
    expect_engine(Engine.find_by_name('2.2L CNG I4 DOHC 16V FI Engine'),
        :cylinders     => 4,
        :configuration => 'I',
        :aspiration    => 'NA',
        :fuel          => 'N',
        :displacement  => "2.2")
  end

  def expect_engine(engine,options)
    engine.cylinders.should == options[:cylinders]
    engine.configuration.should == options[:configuration]
    engine.aspiration.should == options[:aspiration]
    engine.fuel.should == options[:fuel]
    engine.displacement.to_s.should == options[:displacement] if options[:displacement]
  end

  it "can import all transmissions and verify their names have been trimmed" do
    Transmission.count.should == 11

    Transmission.find(:all).each do |t|
      t.name.strip.should == t.name
    end
  end

  it "can verify the transmission parameters for the '4-Speed Automatic Transmission'" do
    expect_transmission(Transmission.find_by_name('4-Speed Automatic Transmission'),
        :speed => 4,
        :kind  => Transmission::AUTOMATIC)
  end

  it "can verify the transmission parameters for the 'Auxiliary Transmission Fluid Cooler'" do
    expect_transmission(Transmission.find_by_name('Auxiliary Transmission Fluid Cooler'),
        :speed => nil,
        :kind  => nil)
  end

  it "can verify the transmission parameters for the '5-Speed Manual Transmission'" do
    expect_transmission(Transmission.find_by_name('5-Speed Manual Transmission'),
        :speed => 5,
        :kind  => Transmission::MANUAL)
  end

  it "can verify the transmission parameters for the '5-Speed Automatic Transmission'" do
    expect_transmission(Transmission.find_by_name('5-Speed Automatic Transmission'),
        :speed => 5,
        :kind  => Transmission::AUTOMATIC)
  end

  def expect_transmission(transmission,options)
    transmission.speed.should == options[:speed]
    transmission.kind.should == options[:kind]
  end

  it "can import all colors and verify names are trimmed" do
    Color.count.should == 12367

    Color.find_all_by_name("Black").each do |c|
      c.name.strip.should == c.name
    end
  end

  it "can import all VIN data" do
    Vin.count.should == 1368
  end

  it "should verify the data for ad_style_id 19040" do
    expect_for_style(Style.find_by_ad_style_id(19040),
        :model                  => 'Cavalier',
        :motorizations_count    => 2,
        :standard_engine        => "2.2L I4 OHV 8V FI Engine",
        :optional_engines       => ["2.4L I4 DOHC 16V FI Engine"],
        :clutches_count         => 2,
        :standard_transmission  => "5-Speed Manual Transmission",
        :optional_transmissions => ["4-Speed Automatic Transmission"],
        :exterior_colors_count  => 9,
        :exterior_colors        => ["Alpine Green Metallic", "Black", "Bright Red", "Bright White", "Forest Green",
                                    "Indigo Blue Metallic", "Mayan Gold Metallic", "Sandrift Metallic",
                                    "Ultra Silver Metallic"],
        :interior_colors_count  => 2,
        :interior_colors        => ["Graphite", "Neutral"],
        :vins_count             => 5,
        :vins                   => ["3G1JF5242S", "3G1JF52F2S", "1G1JF52F27", "1G1JF52427", "1G1JF52T27"])
  end

  it "should verify the data for ad_style_id 100529060" do
    expect_for_style(Style.find_by_ad_style_id(100529060),
        :model                  => "Silverado 1500 SS",
        :motorizations_count    => 1,
        :standard_engine        => "6.0L V8 OHV 16V FI Engine",
        :optional_engines       => [],
        :clutches_count         => 1,
        :standard_transmission  => "4-Speed Automatic Transmission",
        :optional_transmissions => [],
        :exterior_colors_count  => 3,
        :exterior_colors        => ["Black", "Silver Birch Metallic", "Victory Red"],
        :interior_colors_count  => 1,
        :interior_colors        => ["Dark Charcoal"],
        :vins_count             => 1,
        :vins                   => ["2GCEC19N51"])
  end

  it "should verify the data for ad_style_id 100274259" do
    expect_for_style(Style.find_by_ad_style_id(100274259),
        :model                  => "Tahoe",
        :motorizations_count    => 2,
        :standard_engine        => "5.3L Flex Fuel V8 OHV 16V FI Engine",
        :optional_engines       => ["5.3L V8 OHV 16V FI Engine"],
        :clutches_count         => 1,
        :standard_transmission  => "4-Speed Automatic Transmission",
        :optional_transmissions => [],
        :exterior_colors_count  => 5,
        :exterior_colors        => ["Black", "Dark Green Metallic", "Silver Birch Metallic", "Sport Red Metallic",
                                   "Summit White"],
        :interior_colors_count  => 2,
        :interior_colors        => ["Gray/Dark Charcoal", "Tan/Neutral"],
        :vins_count             => 4,
        :vins                   => ["1GNEK13Z4R", "1GNEK13T4R", "1GNEK13T4J", "1GNEK13Z4J"])
  end

  it "should verify the data for ad_style_id 100364205" do
    expect_for_style(Style.find_by_ad_style_id(100364205),
        :model                  => "Phaeton",
        :motorizations_count    => 1,
        :standard_engine        => "6.0L W12 DOHC 48V FI Engine",
        :optional_engines       => [],
        :clutches_count         => 1,
        :standard_transmission  => "5-Speed Automatic Transmission",
        :optional_transmissions => [],
        :exterior_colors_count  => 1,
        :exterior_colors        => ["Black Klavierlack"],
        :interior_colors_count  => 1,
        :interior_colors        => ["Sonnen Beige"],
        :vins_count             => 1,
        :vins                   => ["WVWAH63D48"])
  end

  it "should verify the data for ad_style_id 100377732" do
    expect_for_style(Style.find_by_ad_style_id(100377732),
        :model                  => "Touareg",
        :motorizations_count    => 1,
        :standard_engine        => "4.9L Turbocharged Diesel V10 SOHC 20V FI Engine",
        :optional_engines       => [],
        :clutches_count         => 1,
        :standard_transmission  => "6-Speed Automatic Transmission",
        :optional_transmissions => [],
        :exterior_colors_count  => 10,
        :exterior_colors        => ["Black", "Blue Silver Metallic", "Campanella White", "Colorado Red Metallic",
                                    "Offroad Gray Metallic", "Reed Green Metallic", "Reflex Silver Metallic",
                                    "Shadow Blue Metallic", "Venetian Green Metallic", "Wheat Beige Metallic"],
        :interior_colors_count  => 8,
        :interior_colors        => ["Anthracite", "Anthracite", "Kristal Gray", "Kristal Gray", "Pure Beige",
                                    "Pure Beige", "Teak", "Teak"],
        :vins_count             => 4,
        :vins                   => ["WVGHH67L4D", "WVGPZ77L4D", "WVGHH77L4D", "WVGGH77L4D"])
  end

  def expect_for_style(style, options)
    options.each_pair do |key, value|
      want_count, attribute = /(.*)_count/.match(key.to_s).to_a
      if want_count
        style.send(attribute).size.should == value.to_i
      else
        if value.class == Array
          attribute_names = style.send(key).collect(&:name)
          value.each do |name|
            attribute_names.should include(name)
          end
        else
          style.send(key).name.should == value
        end
      end
    end
  end

end
