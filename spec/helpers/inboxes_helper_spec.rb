require File.dirname(__FILE__) + '/../spec_helper'
require 'hpricot'

describe InboxesHelper, "#timing" do
  helper_name "inboxes"

  it "shows when an active listing will end" do
    listing = listings(:bobs_listing_1)
    Time.stub!(:now).and_return(listing.auction_start)
    timing(listing, :seller => true).should == "Ends: 14 days from now"
  end

  it "shows that a listing has expired" do
    listing = listings(:bobs_listing_1)
    listing.update_attribute(:auction_start, Time.now() - 25.days)
    Listing.expire_listings

    listing.reload
    timing(listing, :seller => false).should == "Ended: No Sale"
  end

  it "shows when an unstarted listing will start" do
    listing = listings(:bobs_listing_1)
    Time.stub!(:now).and_return(listing.auction_start - 1.day)
    timing(listing, :seller => true).should == "Starts: 1 day from now"
  end

end

describe InboxesHelper, "#activity_time" do
  helper_name "inboxes"

  before :each do
    @date_time = Time.now
    date_time_html = activity_time(@date_time)

    @date_time_doc = Hpricot(date_time_html)
  end

  it "should display the specified time in the appropriate format" do
    bold = @date_time_doc.at("/")

    time = bold.children.first
    time.to_plain_text.should == as_time(@date_time)

    br = bold.next
    br.to_plain_text.should == "\n"

    date = br.next
    date.to_plain_text.should == as_date(@date_time)
  end
end