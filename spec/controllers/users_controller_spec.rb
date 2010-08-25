require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "#update" do
  controller_name :users

  before(:each) do
    @user = users(:bob)
    log_in(@user)
  end

  it "should update sms address" do
    old_sms_address = @user.sms_address
    new_sms_address = '4155551212@vtext.com'

    put :update, :id => @user.to_param, :user => { :sms_address => new_sms_address }
    @user.reload
    @user.sms_address.should_not == old_sms_address
    @user.sms_address.should == new_sms_address
  end

  it "should remove all non-digit characters from the phone number portion of the sms_address before saving" do
    put :update, :id => @user.to_param, :user => { :sms_address => '(206)555-1212@vtext123.com' }
    @user.reload
    @user.sms_address.should == '2065551212@vtext123.com'
  end

  it "should deal with no sms_address parameter" do
    old_sms_address = @user.sms_address

    put :update, :id => @user.to_param, :user => {}
    @user.reload
    @user.sms_address.should == old_sms_address
  end

  it "should deal with an sms_address parameter with no @" do
    put :update, :id => @user.to_param, :user => { :sms_address => '(206)555-1212' }
  end

  it "should update sms receive preferences" do
    old_wants_any_sms_preference = @user.sms_wants_any_sms
    old_wants_new_offer_preference = @user.sms_wants_new_offer
    old_wants_listing_expired_preference = @user.sms_wants_listing_expired
    old_wants_inquiry_preference = @user.sms_wants_inquiry
    old_wants_reply_preference = @user.sms_wants_reply
    old_wants_auction_won_preference = @user.sms_wants_auction_won
    old_wants_auction_lost_preference = @user.sms_wants_auction_lost
    old_wants_auction_cancel_preference = @user.sms_wants_auction_cancel

    put :update, :id => @user.to_param, :user => { :sms_wants_new_offer => !old_wants_new_offer_preference,
                                                    :sms_wants_inquiry => !old_wants_inquiry_preference,
                                                    :sms_wants_reply => !old_wants_reply_preference }
    @user.reload
    @user.sms_wants_any_sms.should          == old_wants_any_sms_preference
    @user.sms_wants_new_offer.should_not    == old_wants_new_offer_preference
    @user.sms_wants_new_offer.should        == !old_wants_new_offer_preference
    @user.sms_wants_listing_expired.should  == old_wants_listing_expired_preference
    @user.sms_wants_inquiry.should_not      == old_wants_inquiry_preference
    @user.sms_wants_inquiry.should          == !old_wants_inquiry_preference
    @user.sms_wants_reply.should_not        == old_wants_reply_preference
    @user.sms_wants_reply.should            == !old_wants_reply_preference
    @user.sms_wants_auction_won.should      == old_wants_auction_won_preference
    @user.sms_wants_auction_lost.should     == old_wants_auction_lost_preference
    @user.sms_wants_auction_cancel.should   == old_wants_auction_cancel_preference

    put :update, :id => @user.to_param, :user => { :sms_wants_new_offer => !old_wants_new_offer_preference,
                                                   :sms_wants_listing_expired => !old_wants_listing_expired_preference }
    @user.reload
    @user.sms_wants_new_offer.should_not == old_wants_new_offer_preference
    @user.sms_wants_new_offer.should == !old_wants_new_offer_preference
    @user.sms_wants_listing_expired.should_not == old_wants_listing_expired_preference
    @user.sms_wants_listing_expired.should == !old_wants_listing_expired_preference
    
    put :update, :id => @user.to_param, :user => { :sms_wants_auction_won => !old_wants_auction_won_preference,
                                                    :sms_wants_auction_cancel => !old_wants_auction_cancel_preference }
    
    @user.reload
    @user.sms_wants_auction_won.should_not == old_wants_auction_won_preference
    @user.sms_wants_auction_won.should == !old_wants_auction_won_preference
    @user.sms_wants_auction_cancel.should_not == old_wants_auction_cancel_preference
    @user.sms_wants_auction_cancel.should == !old_wants_auction_cancel_preference
  end
end