# == Schema Information
# Schema version: 52
#
# Table name: shopping_items
#
#  id                :integer(11)     not null, primary key
#  created_at        :datetime        
#  updated_at        :datetime        
#  dealership_id     :integer(11)     
#  originator_id     :integer(11)     
#  priority          :boolean(1)      
#  min_year          :integer(11)     
#  max_year          :integer(11)     
#  make_id           :string(255)     
#  model_id          :integer(11)     
#  min_odometer      :integer(11)     
#  max_odometer      :integer(11)     
#  min_price         :integer(11)     
#  max_price         :integer(11)     
#  max_distance      :integer(11)     
#  must_be_certified :boolean(1)      
#

class ShoppingItem < ActiveRecord::Base

  after_create   :find_matching_listings
  # after_update   :find_matching_listings -- right now can only set "priority" which
  #  probably shouldn't trigger another search
  
  MINIMUM_YEAR = 1981
  MAXIMUM_YEAR = Time.now.year + 1

  before_validation :set_dealership

  belongs_to :dealership
  belongs_to :originator, :class_name => 'User', :foreign_key => :originator_id
  belongs_to :make, :class_name =>  "Evd::Make", :foreign_key => :make_id
  belongs_to :model, :class_name =>  "Evd::Model", :foreign_key => :model_id
  
  validates_presence_of :dealership
  validates_presence_of :originator

  validates_numericality_of :min_year, :only_integer => true, :allow_nil => true
  validates_numericality_of :max_year, :only_integer => true, :allow_nil => true

  validates_numericality_of :min_price, :allow_nil => true
  validates_numericality_of :max_price, :allow_nil => true

  def validate
    # do we care at all about year? make sure it's 4 digits maybe?
    if (min_year && max_year) && (min_year > max_year)
      errors.add_to_base "Min Year must be less than Max Year"
    end
    if (min_price && max_price) && (min_price > max_price)
      errors.add :min_price, "Min Price must be less than Max Price"
    end
    if (min_odometer && max_odometer) && (min_odometer > max_odometer)
      errors.add :min_odometer, "Min Mileage must be less than Max Mileage"
    end
  end

  def self.find_shoppers(listing)
    # find unique dealerships with shopping items that match this listing
    #   if more than one shopping item, just choose first (future issue when >1 users per dealership)
    vehicle = listing.vehicle
    trim    = vehicle.trim
    model   = trim.model
    dealership = listing.dealership
    vehicle_year = yearcode_to_year(trim.yearcode)
    
    ShoppingItem.find_by_sql("""
      SELECT shopping_items.*
        FROM users,
             shopping_items,
             dealerships,
             locations
       WHERE users.id = shopping_items.originator_id
         AND  shopping_items.dealership_id <> #{listing.dealership_id}
         AND ((shopping_items.make_id IS NULL) OR ('#{model.make_id}' = shopping_items.make_id))
         AND ((shopping_items.model_id IS NULL) OR (#{model.id} = shopping_items.model_id))
         AND ((shopping_items.min_year IS NULL) OR (#{vehicle_year} >= shopping_items.min_year))
         AND ((shopping_items.max_year IS NULL) OR (#{vehicle_year} <= shopping_items.max_year))
         AND ((shopping_items.min_odometer IS NULL) OR (#{vehicle.odometer} >= shopping_items.min_odometer))
         AND ((shopping_items.max_odometer IS NULL) OR (#{vehicle.odometer} <= shopping_items.max_odometer))
         AND ((shopping_items.min_price IS NULL) OR (#{listing.asking_price} >= shopping_items.min_price))
         AND ((shopping_items.max_price IS NULL) OR (#{listing.asking_price} <= shopping_items.max_price))
         AND (((shopping_items.max_distance IS NULL) OR (shopping_items.max_distance = 0))
             OR (
                (#{distance_sql(dealership)} <= shopping_items.max_distance))
            AND (dealerships.location_id = locations.id)
            AND (shopping_items.dealership_id = dealerships.id)
                )
         AND ((NOT shopping_items.must_be_certified) OR #{vehicle.certified})
    GROUP BY originator_id
    """)
  end
  
  private
  def set_dealership
    self.dealership = self.originator.dealership if self.originator && self.dealership.nil?
  end

  def find_matching_listings
    filters = {}
    filters[:make_id] = make_id if make_id
    filters[:model_id] = model_id if model_id && model_id != Evd::Model::ANY
    filters[:min_year] = min_year if min_year
    filters[:max_year] = max_year if max_year
    filters[:min_odometer] = min_odometer if min_odometer
    filters[:max_odometer] = max_odometer if max_odometer
    filters[:min_price] = min_price if min_price
    filters[:max_price] = max_price if max_price
    filters[:max_distance] = max_distance if (max_distance && max_distance > 0)
    filters[:must_be_certified] = must_be_certified if must_be_certified
    Listing.find_for_shopping_item(:user => originator, :filter => filters, :dealership => self.dealership).each do |listing|
      theProspect = self.dealership.prospects.find_by_listing_id(listing.id)
      if (theProspect)
        theProspect.update_attributes(:source => 'Shopping List', :lost_interest => false)
      else
        theProspect = Prospect.create(:prospector => originator,
                                      :dealership => self.dealership,
                                      :listing    => listing,
                                      :source     => 'Shopping List')
      end
      ShoppingItemEvent.create(:originator => originator,
                               :prospect => theProspect,
                               :comment => nil
                               )
    end
  end

end
