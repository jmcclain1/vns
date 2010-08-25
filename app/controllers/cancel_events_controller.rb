class CancelEventsController < ApplicationController

  before_filter :set_listing

  def create
    attributes = {:originator => logged_in_user}
    attributes.merge!(params[:event])
    @listing.cancel(attributes)

    redirect_to listings_path
  end

  protected
  def set_listing
    @listing  = logged_in_user.dealership.listings.find(params[:listing_id])
    raise "Couldn't find listing #{params[:listing_id]}" unless @listing
  end
end
