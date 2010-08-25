require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "listing_recipients_view" do
  include ListingsHelperMethods

  before do
    @listing = listings(:bobs_listing_1)
    assigns[:partners] = User.find(:all)
    assigns[:listing] = @listing
    assigns[:logged_in_user] = users(:bob)
  end

  def view_name
    "/listings/wizard/recipients.mab"
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
    doc.at("//div[@id='wizard_bar']//li[4]")[:class].should == 'active'
  end

  it "should render a form that submits to the controller" do
    doc = render_view
    doc.at("//form")["action"].should == listing_recipients_path(@listing)
    doc.at("//form/a[@id='submit_btn']") == "Proceed to Verify and Create"
  end

  it "should have appropriate help content" do
    doc = render_view
    doc.at("//td[@class='helper']/h3").innerHTML.should include('Specify Recipients')
  end

  it "should check the checkboxes for the users on the recipient list" do
    @listing.stub!(:recipients).and_return([users(:charlie)])
    doc = render_view
    doc.at("//input[@value='validcharlie']")[:checked].should == 'checked'
  end

  it "should not check the checkboxes for users not on the recipient list" do
    @listing.stub!(:recipients).and_return([users(:charlie)])
    doc = render_view
    doc.at("//input[@value='validbob']")[:checked].should_not == 'checked'
  end
end
