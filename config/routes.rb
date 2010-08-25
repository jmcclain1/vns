ActionController::Routing::Routes.draw do |map|
  map.connect 'partners/add_partners_TEMP_DANGEROUS', :controller => 'partners', :action => 'add_partners_TEMP_DANGEROUS'
  map.connect 'transaction/index_pending', :controller => 'transactions', :action => 'index_pending'

  map.listing_details 'listings/:id/details',          :controller => 'listings', :action => 'show', :tertiary_tab => 'listing_details'
  map.listing_buyers  'listings/:id/buyers/:buyer_id', :controller => 'listings', :action => 'show', :tertiary_tab => 'messages_and_offers', :defaults => {:buyer_id => nil}
  map.complete_sale 'listings/:id/complete_sale', :controller => 'listings', :action => 'complete_sale'
  # map.listing_relist 'listings/:id/relist', :controller => 'listings', :action => 'relist'
  
  map.resources :listings do |listing|
    listing.resource :vehicle, :controller => 'listing_vehicle', :name_prefix => 'listing_'
    listing.resource :info, :controller => 'listing_info', :name_prefix => 'listing_'
    listing.resource :terms, :controller => 'listing_terms', :name_prefix => 'listing_'
    listing.resource :recipients, :controller => 'listing_recipients', :name_prefix => 'listing_'
    listing.resource :summary, :controller => 'listing_summary', :name_prefix => 'listing_'
    listing.resource :auction_period, :controller => 'listing_auction_period', :name_prefix => 'listing_'

    listing.resource :cancel, :controller => 'cancel_events', :name_prefix => 'listing_'
    listing.resource :relist, :controller => 'relist_events', :name_prefix => 'listing_'
  end

  map.prospect_details  'prospects/:id/details', :controller => 'prospects', :action => 'show', :tertiary_tab => 'listing_details'
  map.prospect_messages 'prospects/:id/messages/:panel', :controller => 'prospects', :action => 'show', :tertiary_tab => 'messages_and_offers', :defaults => {:panel => nil}
  map.prospect_preview  'prospects/:listing_id/preview', :controller => 'prospects', :action => 'preview'
  
  map.resources :prospects do |prospect|
    prospect.resource :accept, :controller => 'accept_events', :name_prefix => 'prospect_'
    prospect.resource :ask,    :controller => 'ask_events',    :name_prefix => 'prospect_'
    prospect.resource :reply,  :controller => 'reply_events',  :name_prefix => 'prospect_'
    prospect.resource :offer,  :controller => 'offer_events',  :name_prefix => 'prospect_'
  end
  
  map.resources :vehicles
  map.resources :notifications
  map.resources :inventory_items
  map.resources :tabs
  map.resources :partners
  map.resources :shopping_items
  map.resources :transactions

  map.home_page '', :controller => "home", :action => "index"
  map.routes_from_plugin('user')
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
