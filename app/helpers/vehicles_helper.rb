module VehiclesHelper
  include MarkabyHelper

  def create_listing_button(vehicle)
    markaby do
      form :action => '/listings', :method => :post, :id => "create_listing_form_#{vehicle.to_param}" do |f|
        title = vehicle.listing.nil? ? "Create Listing" : "Continue Listing"
        form_btn title, :id => "create_listing_btn_#{vehicle.to_param}", :style => 'text-align: right;', :class => ('button_disabled' unless vehicle.listable?), :onclick => (vehicle.listable? ? "$('create_listing_form_#{vehicle.to_param}').submit();" : "return false;")
        input :type => :hidden, :name => 'listing[vehicle_id]', :value => vehicle.to_param
      end
    end
  end
end
