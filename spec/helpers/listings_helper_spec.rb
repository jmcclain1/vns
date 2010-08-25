require File.dirname(__FILE__) + '/../spec_helper'
require 'hpricot'

describe ListingsHelper do
  include ActionController::UrlWriter
  helper_name "listings"

  it "doesn't blow up when there are no prospects" do
    listing = listings(:bobs_listing_1)
    listing.prospects.delete_all
    html = prospect_message_container(listing)
    doc = Hpricot(html)
  end
end