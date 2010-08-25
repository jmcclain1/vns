dir = File.dirname(__FILE__)
require "#{dir}/../spec_helper"

describe TermsOfServiceController, "#route_for" do
  include ActionController::UrlWriter

  it "should map { :controller => 'terms_of_service', :action => 'show' } to /terms_of_service" do
    route_for(:controller => "terms_of_service", :action => "show").should == "/terms_of_service"
  end

  it "should support show helper method: terms_of_service_path" do
    terms_of_service_path.should == "/terms_of_service"
  end
end

describe TermsOfServiceController, "#show" do
  it "should show latest revision of terms of service text" do
    get :show
    assigns(:terms_of_service).should == terms_of_services(:tos_rev_3)
  end
end