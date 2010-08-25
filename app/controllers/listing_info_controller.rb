class ListingInfoController < ListingResourceController

  def update
    find_listing
    @listing.update_attributes(params[:listing])
    if @listing.save(false)
      redirect_to(listing_terms_url(@listing))
    else
      flash[:notice] = @listing.errors.full_messages
      render_edit
    end
  end

  protected
  def render_edit
    @vehicle = @listing.vehicle
    render :template => '/listings/wizard/info'
  end

end
