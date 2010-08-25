class ListingTermsController < ListingResourceController

  def update
    find_listing
    if @listing.update_attributes(params[:listing])
      redirect_to(listing_recipients_url(@listing))
    else
      flash[:notice] = @listing.errors.full_messages
      render_edit
    end
  end

  protected

  def render_edit
    render :template => '/listings/wizard/terms'
  end

end
