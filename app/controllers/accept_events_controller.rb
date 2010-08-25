class AcceptEventsController < ApplicationController

  # There isn't an AcceptEvent, only WonEvents and LostEvents.  AcceptEvent is
  # a 'virtual' event that causes the Won/Lost events to be generated.

  before_filter :set_prospect

  def create
    terms_accepted = params[:agree_to_terms]
    if terms_accepted
      attributes = {:originator => logged_in_user}
      attributes.merge!(params[:event])
      @prospect.accept(attributes)

      redirect_to listing_buyers_path(:id => @prospect.listing.id, :buyer_id => @prospect.id)
    else
      flash[:notice] = "You must accept the terms"

      accept_panel_name = "spot_market_accept_offer_#{@prospect.id}"
      redirect_to listing_buyers_path(:id => @prospect.listing.id, :buyer_id => @prospect.id, :panel => accept_panel_name)
    end
  end

  private
  def set_prospect
    @prospect = logged_in_user.dealership.prospects_for_acceptance.find(params[:prospect_id])
    raise "Prospect #{params[:prospect_id]} not found" unless @prospect
  end
end
