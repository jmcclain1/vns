class PartnersController < ApplicationController
  # GET /partners
  # GET /partners.xml
  def index
    @user = logged_in_user
    respond_to do |format|
      format.html
      format.js  { extract_livegrid_params(params)
                   render :layout => false,
                          :content_type => 'application/xml',
                          :action => "index.rxml" }
    end
  end

  #TODO: REMOVE THIS ONCE WE CAN ADD PARTNERS! (fm)
  def add_partners_TEMP_DANGEROUS
    User.find(:all).each do |user|
      Partnership.create(:inviter => logged_in_user, :receiver => user) if logged_in_user.dealership != user.dealership
    end
    redirect_to :back
  end

  # GET /partners/1
  # GET /partners/1.xml
  def show
  end

  # GET /partners/new
  def new
  end

  # GET /partners/1;edit
  def edit
  end

  # POST /partners
  # POST /partners.xml
  def create
  end

  # PUT /partners/1
  # PUT /partners/1.xml
  def update
  end

  # DELETE /partners/1
  # DELETE /partners/1.xml
  def destroy
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Manage'
  end

  def extract_livegrid_params(params)
    params[:user] = logged_in_user

    @want_row_count = (params[:get_total] == 'true')
    @total_rows = logged_in_user.partners.size if @want_row_count
    @offset = params[:offset] || '0'
    @partners = Partnership.paginate(params)
  end
end
