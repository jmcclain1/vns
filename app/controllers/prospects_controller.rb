class ProspectsController < ApplicationController

  before_filter :set_dealership

  def index
    respond_to do |format|
      format.html
      format.js  { @total_rows = @dealership.count_for_buying_tab
                   @prospects = extract_livegrid_params(params) {|params| Prospect.paginate(params)}
                   render :layout => false,
                          :content_type => 'application/xml',
                          :action => "index.rxml" }
    end
  end

  def show
    @prospect = @dealership.prospects.find(params[:id])
    logged_in_user.notifications.for_prospect(@prospect).each {|n| n.clear_unread}
    # TODO: the following line goes away when the vehicle partial is refactored to use locals
    @vehicle = @prospect.listing.vehicle

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @prospect.to_xml }
    end
  end

  def new
    respond_to do |format|
      format.html {
        @shopping_item = ShoppingItem.new(params[:shopping_item] || {}) }
      format.js   { 
       params[:dealership] = @dealership
                    params[:user] = logged_in_user
                    @total_rows = Listing.count_for_search(params)
                    @listings = extract_livegrid_params(params) {|params| Listing.paginate_for_search(params)}
                    render :layout => false,
                           :content_type => 'application/xml',
                           :action => "new.rxml" }
    end
  end

  def create
    @prospect = logged_in_user.prospects.find_by_listing_id(params[:listing_id]) || Prospect.new
    attributes = { :prospector    => logged_in_user,
                   :dealership    => @dealership,
                   :listing       => Listing.find(params[:listing_id]),
                   :source        => 'Find Vehicle',
                   :lost_interest => false}
    attributes.merge!(params[:prospect] || {})
    @prospect.update_attributes(attributes)

    respond_to do |format|
      if @prospect.errors.empty?
        format.html { redirect_to prospect_messages_path(@prospect) }
        format.xml  { head :created, :location => prospect_url(@prospect) }
      else
        flash[:notice] = @prospect.errors.full_messages
        format.html { redirect_to prospects_path }
        format.xml  { render :xml => @prospect.errors.to_xml }
      end
    end
  end
  
  def preview
    @prospect = logged_in_user.prospects.find_by_listing_id(params[:listing_id]) || Prospect.new
    attributes = { :prospector    => logged_in_user,
                   :dealership    => @dealership,
                   :listing       => Listing.find(params[:listing_id]),
                   :source        => 'Find Vehicle',
                   :lost_interest => true}
    attributes.merge!(params[:prospect] || {})
    @prospect.update_attributes(attributes)

    respond_to do |format|
      if @prospect.errors.empty?
        format.html { redirect_to prospect_details_path(@prospect) }
        format.xml  { head :created, :location => prospect_url(@prospect) }
      else
        flash[:notice] = @prospect.errors.full_messages
        format.html { redirect_to prospects_path }
        format.xml  { render :xml => @prospect.errors.to_xml }
      end
    end
  end
  
  def destroy
    @prospect = Prospect.find(params[:id])
    logged_in_user.notifications.for_prospect(@prospect).each {|n| n.clear_unread}
    @prospect.lose_interest

    if tabs = session[:tablist]
      if tab = tabs["#{session[:user_id]}_prospects"]
        if tab[:id] == @prospect.id
          session[:tablist]["#{session[:user_id]}_prospects"] = nil
        end
      end
    end
    
    respond_to do |format|
      format.html { redirect_to prospects_url }
      format.xml  { head :ok }
    end
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Buying'
  end

  def extract_livegrid_params(params)
    params[:user] = logged_in_user
    @want_row_count = (params[:get_total] == 'true')
    @offset = params[:offset] || '0'
    yield(params)
  end
end
