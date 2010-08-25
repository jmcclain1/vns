class ListingsController < ApplicationController

  before_filter :set_dealership

  def index
    respond_to do |format|
      format.html # index.rhtml
      format.js  { extract_livegrid_params(params)
                   render :layout => false,
                          :content_type => 'application/xml',
                          :action => "index.rxml" }
    end
  end

  def show
    @listing = logged_in_user.dealership.listings.find(params[:id])
    @vehicle = @listing.vehicle
    
    if buyer_id = params[:buyer_id]
      logged_in_user.notifications.for_listing(@listing).each {|n|
       if n.originator.id.to_i == buyer_id.to_i
         n.clear_unread
       end
      }
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @listing.to_xml }
    end
  end

  def new
    create
  end

  def edit
    @listing = logged_in_user.dealership.listings.find(params[:id])
  end

  def create
    defaults = listing_defaults
    defaults.merge!(params[:listing]) if params[:listing]
    @listing = Listing.new(defaults)
    if (@listing.vehicle && @listing.vehicle.listing)
      @listing = @listing.vehicle.listing
    else
      @listing.save(false)  # skip validation
    end
    if (@listing.vehicle)
      redirect_to listing_info_url(@listing)
    else
      redirect_to listing_vehicle_url(@listing)
    end
  end

  def update
    @listing = logged_in_user.dealership.listings.find(params[:id])

    respond_to do |format|
      if @listing.update_attributes(params[:listing])
        flash[:notice] = 'Listing was successfully updated.'
        format.html { redirect_to listing_url(@listing) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @listing.errors.to_xml }
      end
    end
  end

  def destroy
    @listing = logged_in_user.dealership.listings.find(params[:id])
    @listing.destroy

    respond_to do |format|
      format.html { redirect_to listings_url }
      format.xml  { head :ok }
    end
  end

  #todo: make RESTful
  def complete_sale
    @listing = logged_in_user.dealership.listings.find(params[:id])
    @listing.complete_sale
    redirect_to(listings_path)
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Selling'
  end

  def listing_defaults
    {:lister => logged_in_user, :dealership => logged_in_user.dealership }
  end

  def extract_livegrid_params(params)
    params[:user] = logged_in_user

    @want_row_count = (params[:get_total] == 'true')
    @total_rows = @dealership.listings.count if @want_row_count
    @offset = params[:offset] || '0'
    @listings = Listing.paginate(params)
  end
end
