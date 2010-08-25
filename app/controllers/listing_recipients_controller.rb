class ListingRecipientsController < ListingResourceController

  before_filter :find_partners

  def update
    find_listing

    # Note: has_many :through breaks the "clear" method. It doesn't work, yet
    # doesn't complain. So we have to destroy all the connecting objects directly.
    Recipientship.delete_all("listing_id = #{@listing.id}")

    if users = params[:user]
      users.each do |username|
        @listing.recipients << User.find_by_unique_name(username)
      end
    end
    if @listing.save
      redirect_to(listing_summary_url(@listing))
    else
      #todo: test?
      flash[:notice] = @listing.errors.full_messages
      render_edit
    end
  end

  protected
  def render_edit
    render :template => '/listings/wizard/recipients'
  end

  def find_partners
    @partners = User.find(:all) - [logged_in_user]
  end

end
