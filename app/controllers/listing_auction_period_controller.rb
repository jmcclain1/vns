#todo: rename ListingPeriodController
#todo: test

class ListingAuctionPeriodController < ListingResourceController

  def update
    find_listing
    @listing.update_attributes(params[:listing])
    if (@listing.errors[:auction_start])
      render :text => @listing.errors[:auction_start]
    else
      @listing.save(false)
      render :partial => '/listings/wizard/auction_period'
    end
  end

end
