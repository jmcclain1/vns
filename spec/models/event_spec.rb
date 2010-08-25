require File.dirname(__FILE__) + '/../spec_helper'

describe Event do

  it "requires an originator and a prospect" do
    ev = Event.new
    ev.valid?

    ev.should have(1).error_on(:originator)
    ev.should have(1).error_on(:prospect)
  end

  it "should associate events with the prospect's listing" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    ask_event = AskEvent.create(:originator => charlie, :prospect => prospect, :comment => "How's the tires?")

    listing = prospect.listing
    listing.events.should include(ask_event)
  end

  it "should update the last_activity field in the prospect and listing" do
    charlie = users(:charlie)
    prospect = prospects(:charlies_interested_in_bobs_listing_1)
    listing = prospect.listing

    prospect.last_activity.should == nil
    listing.last_activity.should  == nil
    ask_event = AskEvent.create(:originator => charlie, :prospect => prospect, :comment => "How's the tires?")
    prospect.last_activity.should == ask_event.updated_at
    listing.last_activity.should  == ask_event.updated_at
  end

end
