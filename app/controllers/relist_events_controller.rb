class RelistEventsController < ApplicationController

  before_filter :set_listing

  def create
    attributes = {:originator => logged_in_user}
    attributes.merge!(params[:event])
    
    @listing.relist
    @relisting = @listing.clone
    @relisting.save
    @relisting.draft_relisting(:logged_in_user => logged_in_user)
    
    redirect_to(listing_info_path(@relisting))
  end

  protected
  def set_listing
    @listing  = logged_in_user.dealership.listings.find(params[:listing_id])
    raise "Couldn't find listing #{params[:listing_id]}" unless @listing
  end
end
