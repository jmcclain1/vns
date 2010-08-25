require File.dirname(__FILE__) + '/../spec_helper'

describe UserValidationToken do
  it "should send out validation email when created" do
    ActionMailer::Base.deliveries.first.should be_nil
    UserValidationToken.create(:user => users(:unvalidated_user))
    ActionMailer::Base.deliveries.first.should_not be_nil
  end
end