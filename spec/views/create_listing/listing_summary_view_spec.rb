require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "listing_summary_view" do
  include ListingsHelperMethods

  before do
    @listing = listings(:bobs_listing_1)
    assigns[:listing] = @listing
    assigns[:vehicle] = @listing.vehicle
  end
  
  it "should use the 'current_step' style for the second element of the wizard bar" do
    render_view.at("//div[@id='wizard_bar']//li[5]")[:class].should == 'active'
  end

  it "should render a form that submits to the controller" do
    form = render_view.at("/form")
    form["action"].should == listing_summary_path(@listing)
    form.at("/a[@id='submit_btn']") == "Proceed to Select Recipients"
  end

  it "should have appropriate help content" do
    render_view.at("//td[@class='helper']//h3").innerHTML.should include('Summary')
  end

  def view_name
    "/listings/wizard/summary.mab"
  end

  def controller_name
    view_name
  end

  def render_view
    render view_name
    Hpricot(response.body)
  end

end
