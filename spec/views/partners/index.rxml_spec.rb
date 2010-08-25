require File.dirname(__FILE__) + '/../../spec_helper'
require 'rexml/document'

include REXML

describe "/vehicles/index.rxml" do
  it "returns the correct partner information in xml" do
    location = mock('a location')
    location.stub!(:display_name).and_return('SF')
    location.stub!(:distance_from).and_return(34.432)

    user = mock("a User")
    user.stub!(:location).and_return(location)
    view.stub!(:logged_in_user).and_return(user)

    partner = mock('a partner')
    dealership = mock('a dealership')
    dealership.stub!(:name).and_return('Big Al')
    partner.stub!(:status).and_return('inactive')
    partner.stub!(:full_name).and_return('Survivor man')
    partner.stub!(:unique_name).and_return('sman')
    partner.stub!(:dealership).and_return(dealership)
    partner.stub!(:location).and_return(location)
    assigns[:want_row_count] = true
    assigns[:total_rows] = 533
    assigns[:offset] = 3

    assigns[:partners] = [partner]
    render "/partners/index.rxml"
    doc = REXML::Document.new(response.body)
    XPath.first(doc,"//rows").attributes['offset'].should == '3'
    XPath.first(doc,"//rowcount").text.should == '533'
    XPath.first(doc,"//td[1]/div//p[1]").text.should == 'Survivor man'
    XPath.first(doc,"//td[1]/div//p[2]").text.should == 'Big Al'
    XPath.first(doc,"//td[2]/div").text.strip.should == 'sman'

    XPath.first(doc,"//td[3]/div//p[1]").text.strip.should == '34 Miles'
    XPath.first(doc,"//td[3]/div//p[2]").text.strip.should == 'SF'

    XPath.first(doc,"//td[4]/div").text.strip.should == 'Inactive'
  end
end