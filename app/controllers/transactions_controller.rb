class TransactionsController < ApplicationController

  def index_pending
    # yes, this is not restful, still figuring out where these belong
    @user = logged_in_user
  end

  def show
    #index_pending
  end
  
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

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Transacting'
  end

  def extract_livegrid_params(params)
    params[:user] = logged_in_user

    @want_row_count = (params[:get_total] == 'true')
    @total_rows = Prospect.count_for_completed_transactions(params)
    @transactions = Prospect.paginate_for_completed_transactions(params)
    @offset = params[:offset] || '0'
  end

end
