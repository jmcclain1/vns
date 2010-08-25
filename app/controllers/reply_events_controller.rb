class ReplyEventsController < ApplicationController

  before_filter :set_prospect

  def create
    attributes = {:originator => logged_in_user, :prospect => @prospect}
    attributes.merge!(params[:event])
    ReplyEvent.create(attributes)

    redirect_to listing_buyers_path(:id => @listing.id, :buyer_id => @prospect.id)
  end

  private
  def set_prospect
    @listing  = logged_in_user.dealership.listings.for_prospect_id(params[:prospect_id])[0] # TODO: can has_finder return an object instead of a list?
    raise "Couldn't find listing for prospect #{params[:prospect_id]}" unless @listing
    @prospect = @listing.prospects.find(params[:prospect_id])
    raise "Couldn't find prospect #{params[:prospect_id]}" unless @prospect
  end
end
