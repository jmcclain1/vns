require File.dirname(__FILE__) + '/../../spec_helper'
require 'hpricot'

describe "/listings/index" do

  before do
    log_in(users(:bob))
    listings = users(:bob).dealership.listings
    assigns[:listings] = listings
  end

end

