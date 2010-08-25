require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/vehicles/wizard/summary" do
  include VehiclesHelper
  include ListingsHelperMethods

  before do
    @vehicle = create_mock_vehicle
    assigns[:vehicle] = @vehicle
    
  end

  def view_name
    "/vehicles/wizard/summary.mab"
  end

  def controller_name
    view_name
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end

  it "should use the 'current_step' style for the fifth element of the wizard bar" do
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[5]")[:class].should == 'active'
  end

  it "should render a boolean as 'Yes'/'No'" do
    doc = render_view
    
    doc.at("//td[@id='certified']").inner_html.should == "Yes"
    doc.at("//td[@id='frame_damage']").inner_html.should == "Yes"
    doc.at("//td[@id='prior_paint']").inner_html.should == "No"
  end

  it "should display the vehicle photo widget" do
    doc = render_view
    doc.at("//iframe[@id = 'vehicle_photos_container']").should_not be(nil)
  end

end
