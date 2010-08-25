require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/listings/wizard/details" do
  include ListingsHelperMethods

  before do
    @vehicle = create_mock_vehicle
    @listing = mock_model(Listing,
      :vehicle => @vehicle,
      :comments => nil
    )
    assigns[:listing] = @listing
    assigns[:vehicle] = @vehicle
  end

  def view_name
    "/listings/wizard/info.mab"
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
    doc.at("//div[@id='wizard_bar']//li[2]")[:class].should == 'active'
  end

  it "should render a form that submits to the controller" do
    form = render_view.at("/form")
    form["action"].should == listing_info_path(@listing)
    form.at("/a[@id='submit_btn']") == "Proceed to Specify Terms"
  end

  it "should have appropriate help content" do
    doc = render_view
    doc.at("//td[@class='helper']//h3").innerHTML.should include('Complete Vehicle Information')
  end

end
