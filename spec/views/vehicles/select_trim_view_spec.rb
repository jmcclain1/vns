require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/vehicles/wizard/trim" do
  include VehiclesHelper

  before do
    @vehicle = assigns[:vehicle] = mock_model(Vehicle, :vin => GOOD_VIN, :features => [])
    @trim_one = mock('Trim one')
    @trim_one.stub!(:id).and_return(2001)
    @trim_one.stub!(:characterization).and_return("2005 Mercedes C-Class C280 Sedan 4Dr Automatic")
    @trim_two = mock('Trim two')
    @trim_two.stub!(:id).and_return(2002)
    @trim_two.stub!(:characterization).and_return("2005 Mercedes C-Class C280 Sedan 4Dr Manual")
    @trims = [ @trim_one, @trim_two ]
    @vehicle.stub!(:trims).and_return(@trims)
    @vehicle.stub!(:trim).and_return(nil)
  end

  def view_name
    "/vehicles/wizard/trim.mab"
  end

  def render_view
    render view_name
    doc = Hpricot(response.body)
    doc.instance_eval do
      def inputs_named(name)
        search("//input").select do |b|
          b[:name] == name    # HPricot has a bug with names involving []s :-(
        end
      end
    end
    doc
  end

  it "should use the 'current_step' trim for the second element of the wizard bar" do
    doc = render_view
    doc.at("//div[@id='wizard_bar']//li[2]")[:class].should == 'active'
  end

  it "should render a radio button for each of the possible selections" do
    doc = render_view
    buttons = doc.inputs_named('vehicle[trim_id]')
    buttons[0][:value].should == @trim_one.id.to_s
    buttons[1][:value].should == @trim_two.id.to_s
  end

  it "should check the first radio button if no trim is set on the vehicle" do
    doc = render_view
    buttons = doc.inputs_named('vehicle[trim_id]')
    buttons[0][:checked].should == 'checked'
    buttons[1][:checked].should == nil
  end

  it "should check the second radio button if the second trim is set on the vehicle" do
    @vehicle.stub!(:trim).and_return(@trim_two)
    doc = render_view
    buttons = doc.inputs_named('vehicle[trim_id]')
    buttons[0][:checked].should == nil
    buttons[1][:checked].should == 'checked'
  end

  it "should have appropriate help content" do
    doc = render_view
    doc.at("//td[@class='helper']/h3").innerHTML.should == '<span class="step">Step 2: </span>Select Vehicle'
    doc.at("//td[@class='helper']/p").innerHTML.should  == 'Select the vehicle from the list below that matches your vehicle.'
  end

end
