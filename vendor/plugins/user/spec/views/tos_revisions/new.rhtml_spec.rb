require File.dirname(__FILE__) + '/../../spec_helper'

describe "/tos_revisions/new.rhtml with an invalid tos" do
  before do
    assigns[:tos_revision] = TermsOfService.create
  end

  it "should display error message" do
    render "/tos_revisions/new.rhtml"
    response.should have_text(/Text can't be blank/i)
  end

end