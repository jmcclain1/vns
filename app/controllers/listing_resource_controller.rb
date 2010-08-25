class ListingResourceController < ApplicationController

  before_filter :set_dealership

  def show
    edit
  end

  def edit
    find_listing
    render_edit
  end

  protected
  def set_navbar_tab
    @current_navbar_tab = 'Selling'
  end

  def find_listing
    id = (params['listing_id'] || params['listing']['id']).to_i
    @listing = Listing.find(id)
    raise "Couldn't find listing #{id}" unless @listing
  end

  def render_edit
    raise NotImplementedError
  end
end
