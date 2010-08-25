require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "Vehicle details partial" do

  before :each do
    @vehicle = vehicles(:jetta_vehicle_1)
    assigns[:vehicle] = @vehicle
  end

  it "should be" do
    render_view :read_only => false
    @details_doc.should_not be_nil
  end

  it "should default to read_only=false if you do not provide a read_only parameter" do
    render_view

    @details_doc.at('//div[@id=details]/div[@id=edit_vehicle_details_popup]').should_not be_nil
  end

  it "should have a header with the text Vehicle Details" do
    render_view :read_only => false
    header = @details_doc.at('//h2')
    header.should_not be_nil
    header.innerText.should == 'Vehicle Details'
  end

  it "should not have an Edit Vehicle Details button if read-only" do
    render_view :read_only => true
    @details_doc.at('//div[@id=details]/div/input[@id=edit_vehicle_details_popup_toggle_button]').should be_nil
  end

  it "should not have an Edit Vehicle Details popup section if read-only" do
    render_view :read_only => true
    @details_doc.at('//div[@id=details]/div[@id=edit_vehicle_details_popup]').should be_nil
  end

  private

  def render_view(locals = {})
    render :partial => 'vehicles/details', :locals => locals
    @details_doc = Hpricot(response.body)
  end
end
