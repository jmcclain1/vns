require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/new.rhtml" do
  before do
    assigns[:user] = User.new
  end

  it "should render a checkbox to accept terms of service" do
    render "/users/new.rhtml"
    response.should have_text(/id=\"accept_terms_of_service\"/)
  end

end