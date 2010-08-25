class ListingSummaryController < ListingResourceController

  def update
    find_listing
    if @listing.save
      @listing.publish
      redirect_to(listing_url(@listing))
    else
      flash[:notice] = @listing.errors.full_messages
      render_edit
    end
  end

  protected

  def render_edit
    @vehicle = @listing.vehicle    

    render :template => '/listings/wizard/summary'
  end

end
