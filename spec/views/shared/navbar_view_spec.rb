require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

class MockRequest
  attr_accessor :session
  def initialize
    @session = {}
  end
end

describe "navbar" do
  include VehiclesHelper

  before do
    user = users(:bob)
    self.log_in(user)

    view.stub!(:logged_in_user).and_return(user)
  end

  TABS = ["Buying", "Selling", "Transacting", "Appraising", "Inventory", "Manage"]
  TABS.each do |tab|
    it "selects tab #{tab}" do
      assigns[:current_navbar_tab] = tab
      doc = render_view
      doc.at("//li[@class=active]//a").inner_html.should include(tab)
    end
  end

  it "doesn't select the tab if it's not current" do
    assigns[:current_navbar_tab] = nil
    doc = render_view
    doc.at("//li[@class=active]").should == nil
  end

  it "includes the 'content for subnav' in the right place" do
    view.stub!(:content_for_subnav).and_return("foo")
    view.stub!('logged_in?'.to_sym).and_return(true)

    doc = render_view
    doc.at("//div[@class=secondary]/div[@class=border]").inner_html.should == "foo"
  end
  
  def render_view
    render "/shared/_navbar.mab"
    Hpricot(response.body)
  end
end
