require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "listing_terms_view" do
  include ListingsHelperMethods

  before do
    @vehicle = create_mock_vehicle
    @listing = mock_model(Listing,
      :vehicle => @vehicle,
      :asking_price => 12000,
      :vehicle_cost => 123.45,
      :vehicle_days_in_inventory => 32,
      :comments => nil,
      :inspection_duration => 1,
      :auction_duration => 3,
      :auction_start => Time.now,
      :accept_trade_rules => true,
      :auction_end => Time.now + 1.day
    )

  end

  def view_name
    "/listings/wizard/terms.mab"
  end

  def controller_name
    view_name
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end
  
  it "should use the 'current_step' style for the second element of the wizard bar" do
    assigns[:listing] = @listing
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[3]")[:class].should == 'active'
  end

  it "should render a form that submits to the controller" do
    assigns[:listing] = @listing
    doc = render_view
    doc.at("//form")["action"].should == listing_terms_path(@listing)
    doc.at("//form/a[@id='submit_btn']") == "Proceed to Select Recipients"
  end

  it "should have appropriate help content" do
    assigns[:listing] = @listing
    doc = render_view
    doc.at("//td[@class='helper']/h3").innerHTML.should include('Specify Terms')
  end

end
