require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/vehicles/wizard/vin" do
  include VehiclesHelper

  def view_name
    "/vehicles/wizard/vin.mab"
  end

  def controller_name
    view_name  # in rspec view specs, the controller is not known, so it uses the name of the view
  end

  before do
    @vehicle = assigns[:vehicle] = mock_model(Vehicle, :vin => nil, :features => [])
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end

  it "should render an empty vin field when vin is nil" do
    doc = render_view
    doc.at("//input[@id='vehicle_vin']")["value"].to_s.should == ''
  end

  it "should render the vin in the vin field" do
    assigns[:vehicle] = mock_model(Vehicle, :vin => "abc")
    doc = render_view
    doc.at("//input[@id='vehicle_vin']")["value"].should == 'abc'
  end

  it "should render the error notice" do
    assigns[:vehicle] = mock_model(Vehicle, :vin => "abc")
    flash[:notice] = "Please enter a valid VIN."
    doc = render_view
    response.body.should =~ /Please enter a valid VIN./
  end

  it "should use the 'current_step' style for the first element of the wizard bar" do
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[1]")[:class].should == 'active'
  end

  it "should have appropriate help content" do
    doc = render_view
    doc.at("//td[@class='helper']/h3").innerHTML.should == '<span class="step">Step 1: </span>Enter VIN'
    doc.at("//td[@class='helper']/p").innerHTML.should  == 'First we need the vehicle VIN. The VNS system will retrieve the vehicle Year, Make, Model and Trim data.'
  end
end
