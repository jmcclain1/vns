# == Schema Information
# Schema version: 52
#
# Table name: prospects
#
#  id            :integer(11)     not null, primary key
#  created_at    :datetime        
#  updated_at    :datetime        
#  listing_id    :integer(11)     
#  dealership_id :integer(11)     
#  prospector_id :integer(11)     
#  watch         :boolean(1)      
#  source        :string(255)     default("")
#  last_activity :datetime        
#  lost_interest :boolean(1)      
#

class Prospect < ActiveRecord::Base
  belongs_to :dealership
  belongs_to :listing
  belongs_to :prospector,
             :class_name => 'User',
             :foreign_key => :prospector_id

  validates_presence_of :dealership
  validates_uniqueness_of :listing_id,
                          :scope => :dealership_id,
                          :message => "You're already watching this listing"
  validates_presence_of :listing
  validates_presence_of :prospector

  has_many :events, :order => "events.created_at DESC, events.id DESC"
  has_many :notifications, :as => :tradeable

  has_finder :interested, :conditions => "NOT prospects.lost_interest"
  
#  has_finder :livegrid_sort, lambda { |params|
  def self.livegrid_sort(params)
    finder = {}
    if params[:s5] # sort by recent activity
      finder[:select]  = 'DISTINCT prospects.*'
      finder[:include] = [ :events ]
      finder[:order]   = "IFNULL(events.updated_at,prospects.updated_at) #{params[:s5]}, prospects.id #{params[:s5]}"
#      finder[:select]  = 'prospects.*, IFNULL(MAX(events.updated_at),prospects.updated_at) AS rank'
#      finder[:joins]   = 'LEFT OUTER JOIN events ON events.prospect_id = prospects.id'
#      finder[:group]   = 'prospects.id'
#      finder[:order]   = "rank #{params[:s5]}, prospects.id #{params[:s5]}"
    else
      finder[:select]  = 'DISTINCT prospects.*'
#      finder[:include] = [ :listing => { :dealership => :location,
#                                         :vehicle => { :trim => { :model => :make }}} ]
      finder[:joins]   = """
        JOIN listings                       ON listings.id    = prospects.listing_id
        JOIN vehicles                       ON vehicles.id    = listings.vehicle_id
        JOIN #{evd_db}.vns_trims  AS trims  ON trims.acode    = vehicles.trim_id
        JOIN #{evd_db}.vns_models AS models ON models.id      = trims.model_id
        JOIN #{evd_db}.vns_makes  AS makes  ON makes.div_code = models.make_id
        JOIN dealerships                    ON dealerships.id = listings.dealership_id
        JOIN locations                      ON locations.id   = dealerships.location_id
      """
      finder[:order]   = case
        when params[:s0] : "trims.yearcode #{params[:s0]}, makes.name, models.name, "
        when params[:s1] : "makes.name #{params[:s1]}, models.name #{params[:s1]}, trims.yearcode, "
        when params[:s2] : "vehicles.odometer #{params[:s2]}, trims.yearcode, makes.name, models.name, "
        when params[:s3] : "#{distance_sort_sql(params[:user].dealership,params[:s3])}, trims.yearcode, makes.name, models.name, "
        when params[:s4] : "listings.asking_price #{params[:s4]}, trims.yearcode, makes.name, models.name, "
        else               "trims.yearcode, makes.name, models.name, "
      end + "prospects.id"
    end
    find(:all,finder)
  end
#  }

  has_finder :livegrid_page, lambda { |params|
    {
      :offset => (params[:offset].nil?    ?  0 : params[:offset].to_i),
      :limit  => (params[:page_size].nil? ? 50 : params[:page_size].to_i)
    }
  }

  def active_offer
    events.find(:first, :conditions => "type = 'OfferEvent'", :order => 'events.created_at DESC, events.id DESC')
  end

  #todo: rename winning_offer to winning_event or something
  
  def winner?
    winning_offer != nil
  end

  def winning_offer
    events.find(:first, :conditions => "type = 'WonEvent'")
  end
  
  def has_high_offer?
    active_offer.amount == listing.high_offer.amount
  end

  def winning_amount
    winning_offer.amount
  end

  def count_events
    events.count(:conditions => "prospect_id = #{self.id}")
  end
  
  def unread_notifications?
    notifications.count(:conditions => "recipient_id = #{listing.lister_id} AND unread = 1") > 0
  end

  def accept(attributes = {})
    listing.accept(self, attributes)
  end
  
  def observers
    if prospector.nil?
      []
    else
      [prospector]
    end
  end

  def self.paginate(params)
    user = params[:user]
    offset = params[:offset] || '0'
    limit  = params[:page_size] || '50'
    if [:s0,:s1,:s2,:s3,:s4,:s5].all? {|s| params[s] == nil}
      params[:s5] = 'DESC'
    end
    order_by = case
      when params[:s0] : "trims.yearcode #{params[:s0]}, "
      when params[:s1] : "makes.name #{params[:s1]}, models.name #{params[:s1]}, "
      when params[:s2] : "vehicles.odometer #{params[:s2]}, "
      when params[:s3] : "#{distance_sort_sql(user.dealership,params[:s3])}, "
      when params[:s4] : "listings.asking_price #{params[:s4]}, "
      when params[:s5] : "prospects.updated_at #{params[:s5]}, prospects.id #{params[:s5]}, "
      else               ""
    end
    order_by += "trims.yearcode, makes.name, models.name, prospects.id"
    Prospect.find_by_sql("""
      SELECT DISTINCT prospects.*
        FROM prospects, listings, vehicles,
             #{evd_db}.vns_trims AS trims, #{evd_db}.vns_models AS models, #{evd_db}.vns_makes AS makes,
             dealerships, locations
       WHERE prospects.listing_id = listings.id
         AND listings.vehicle_id = vehicles.id
         AND dealerships.id = listings.dealership_id
         AND dealerships.location_id = locations.id
         AND vehicles.trim_id = trims.acode
         AND trims.model_id = models.id
         AND models.make_id = makes.div_code
         AND prospects.dealership_id = #{user.dealership.id}
         AND NOT prospects.lost_interest
    ORDER BY #{order_by}
       LIMIT #{offset}, #{limit}
    """)
  end

  def self.count_for_completed_transactions(params)
    user = params[:user]
    Prospect.count_by_sql("""
     SELECT COUNT(*)
     FROM (
      SELECT DISTINCT prospects.*
        FROM prospects,
             listings, 
             events
       WHERE prospects.listing_id = listings.id
         AND ((prospects.dealership_id = #{user.dealership.id})
              OR 
             (listings.dealership_id = #{user.dealership.id}))
         AND listings.state = 'completed'
         AND events.prospect_id = prospects.id
         AND events.type = 'WonEvent'
     )
     AS blah
    """)
  end
  
  def self.paginate_for_completed_transactions(params)
    user = params[:user]
    offset = params[:offset] || '0'
    limit  = params[:page_size] || '50'
    order_by = "prospects.updated_at DESC"
    Prospect.find_by_sql("""
      SELECT DISTINCT prospects.*
        FROM prospects,
             listings, 
             vehicles,
             events,
             #{evd_db}.vns_trims AS trims,
             #{evd_db}.vns_models AS models,
             #{evd_db}.vns_makes AS makes
       WHERE prospects.listing_id = listings.id
         AND listings.vehicle_id = vehicles.id
         AND vehicles.trim_id = trims.acode
         AND trims.model_id = models.id
         AND models.make_id = makes.div_code
         AND ((prospects.dealership_id = #{user.dealership.id})
              OR 
             (listings.dealership_id = #{user.dealership.id}))
         AND listings.state = 'completed'
         AND events.prospect_id = prospects.id
         AND events.type = 'WonEvent'
    ORDER BY #{order_by}
       LIMIT #{offset}, #{limit}
    """)
  end
  
  def removable?
    self.active_offer == nil
  end

  def lose_interest
    if !self.removable?
      raise "Prospect may not be removed if there is an active offer"
    end
    self.update_attribute(:lost_interest, true)
  end

  def regain_interest
    self.update_attribute(:lost_interest, false)
  end
end
