require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/listings/wizard/vehicle" do
  include ListingsHelperMethods

  before do
    @listing = mock_model(Listing)
    assigns[:listing] = @listing
    assigns[:drafts] = []
  end

  def view_name
    "/listings/wizard/vehicle.mab"
  end

  def controller_name
    view_name
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end
  
  it "should use the 'current_step' style for the second element of the wizard bar" do
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[1]")[:class].should == 'active'
  end

  it "should render a form that submits to the controller" do
    doc = render_view
    doc.at("//form")["action"].should == listing_vehicle_path(@listing)
    doc.at("//form/a[@id='submit_btn']") == "Proceed to Complete Vehicle Information"
  end

  it "should have appropriate help content" do
    doc = render_view
    doc.at("//td[@class='helper']/h3").innerHTML.should include('Select Vehicle')
  end

  it "should not show the drafts if there aren't any" do
    doc = render_view
    doc.at("//fieldset[@id='drafts']").should be_nil
  end

  it "renders drafts" do
    draft1 = mock_model(Listing, :vehicle_name => "Awesome racecar", :vehicle_info => "vin123")
    draft2 = mock_model(Listing, :vehicle_name => "Junky jalopy", :vehicle_info => "vin456")
    assigns[:drafts] = [draft1, draft2]
    doc = render_view
    doc.at("//div[@id='drafts']").should_not be_nil
    doc.at("//div[@id='drafts']//li[1]/a")[:href].should == listing_info_path(draft1)
    doc.at("//div[@id='drafts']//li[1]/a").inner_html.should == "Awesome racecar"
    doc.at("//div[@id='drafts']//li[2]/a")[:href].should == listing_info_path(draft2)
    doc.at("//div[@id='drafts']//li[2]/a").inner_html.should == "Junky jalopy"
  end

end
