# == Schema Information
# Schema version: 52
#
# Table name: dealerships
#
#  id          :integer(11)     not null, primary key
#  name        :string(255)     
#  location_id :integer(11)     
#

class Dealership < ActiveRecord::Base
  include Locatable
  
  has_many :traders, :class_name => 'User'
  has_many :all_vehicles, :class_name => "Vehicle"
  has_many :vehicles, :conditions => {:draft => false}
  has_many :draft_vehicles, :class_name => "Vehicle", :conditions => {:draft => true}
  has_many :listings, :conditions => "state <> 'draft' AND state <> 'completed'"
  has_many :draft_listings, :class_name => "Listing", :conditions => "state = 'draft' AND vehicle_id <> 0", :order => "id"
  has_many :prospects
  has_many :active_prospects, :class_name => 'Prospect', :conditions => 'NOT lost_interest'
  has_many :shopping_items
  belongs_to :location

  has_many :prospects_for_acceptance, :through => :listings, :class_name => "Prospect", :source => :prospects

  validates_presence_of :name

  def count_for_buying_tab
    active_prospects.count
  end

  def count_for_selling_tab
    listings.count
  end

  def vins
    vehicles.collect{|v|v.vin}
  end
  
end
