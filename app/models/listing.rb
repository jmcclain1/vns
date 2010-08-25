# == Schema Information
# Schema version: 52
#
# Table name: listings
#
#  id                  :integer(11)     not null, primary key
#  created_at          :datetime        
#  updated_at          :datetime        
#  dealership_id       :integer(11)     not null
#  vehicle_id          :integer(11)     
#  asking_price        :decimal(11, 2)  
#  lister_id           :integer(11)     
#  comments            :text            
#  auction_duration    :integer(11)     
#  auction_start       :datetime        
#  inspection_duration :integer(11)     
#  accept_trade_rules  :boolean(1)      not null
#  last_activity       :datetime        
#  state               :string(255)     default("draft")
#  winning_prospect_id :integer(11)     
#

class Listing < ActiveRecord::Base
  belongs_to :vehicle
  belongs_to :dealership
  belongs_to :lister, :class_name => "User", :foreign_key => 'lister_id'
  belongs_to :winning_prospect, :class_name => "Prospect", :foreign_key => 'winning_prospect_id'
  
  delegate :trim, :to => :vehicle
  delegate :model, :to => :trim
  delegate :make, :to => :model

  has_many :prospects, :include => :events, :order => "events.created_at DESC, prospects.id"
  has_many :recipientships
  has_many :recipients, :through => :recipientships, :foreign_key => "user_id", :class_name => "User"
  has_many :events, :through => :prospects, :order => "events.created_at DESC, events.id DESC"
  has_many :offers, :through => :prospects, :source => :events, :class_name => "Event", :order => "events.amount DESC, events.updated_at", :conditions => "events.type = 'OfferEvent'"
  has_many :notifications, :as => :tradeable

  validates_presence_of :asking_price
  validates_exclusion_of :asking_price, :in => 0..0, :message => "Asking price cannot be zero"
  Infinity = 1.0/0 # zomg
  validates_exclusion_of :asking_price, :in => (-Infinity...0), :message => "Asking price cannot be negative"
  validates_presence_of :vehicle
  validates_presence_of :dealership
  validates_presence_of :lister

  has_finder :for_prospect_id, lambda { |prospect_id|
    {:include => :prospects, :conditions => ["prospects.id = ? AND prospects.listing_id = listings.id",prospect_id]}
  }

  has_finder :active, :conditions => "listings.state IN ('active')"
  
  has_finder :unwatched_by, lambda {|dealership_id|
    { :conditions => """listings.dealership_id <> #{dealership_id}
                AND NOT listings.state IN ('draft')
                AND NOT EXISTS (SELECT *
                                  FROM prospects
                                 WHERE prospects.listing_id = listings.id
                                   AND prospects.dealership_id = #{dealership_id}
                                   AND NOT prospects.lost_interest)
       """ }
  }

  has_finder :apply_filters, lambda {|params|
    dealership = params[:dealership]
    includes = []
    terms    = []
    args     = []
    filters  = params[:filter]
    if filters
#      if filters[:make_id]
#        includes << { :vehicle => :trim } # xx
#        includes << #{evd_db}.model
#        terms << "models.make_id = ?"
#        args << filters[:make_id]
#        if filters[:model_id]
#          # todo
#        end
#      end
#      if filters[:make_id]
#        includes << :vehicle
#        terms << "vehicles.trim.model.make.div_code = ?"
#        args  << filters[:make_id]
#      end
      if filters[:max_odometer]
        includes << :vehicle
        terms << "vehicles.odometer <= ?"
        args  << filters[:max_odometer]
      end
      if filters[:max_price]
        terms << "listings.asking_price <= ?"
        args  << filters[:max_price]
      end
      if filters[:max_distance]
        includes << { :dealership => :location }
        terms << "#{distance_sql(dealership)} <= ?"
        args  << filters[:max_distance]
      end
      if filters[:min_year]
        minyear = filters[:min_year].to_i
        if minyear < 1990  # todo: I don't like this here, but other stuff crashes with earlier years
          minyear = 1990
        end
        min_yearcode = year_to_yearcode(minyear)
        includes << { :vehicle => :trim }
        terms << "vns_trims.yearcode >= ?"
        args << min_yearcode
      end
      if filters[:max_year]
        maxyear = filters[:max_year].to_i
        if maxyear < 1990
          maxyear = 1989 # todo: this is WRONG, but it prevents a crash
        end
        max_yearcode = year_to_yearcode((maxyear + 1).to_s)
        includes << { :vehicle => :trim }
        terms << "vns_trims.yearcode < ?"
        args << max_yearcode
      end
    end
    if terms.empty?
      { }
    else
       { :include => includes, :conditions => [terms.join(' AND '), *args] }
    end
  }

  def self.filter_by_clause(params)
    dealership = params[:dealership]
    filters  = params[:filter]
    filter_by = ""
    if filters
      if filters[:make_id]
        filter_by += " AND makes.div_code = '#{filters[:make_id]}'"
        if filters[:model_id] && filters[:model_id] != Evd::Model::ANY
          filter_by += " AND trims.model_id = '#{filters[:model_id]}'"
        end
      end
      if filters[:min_odometer]
        filter_by += " AND vehicles.odometer >= #{filters[:min_odometer]}"
      end
      if filters[:max_odometer]
        filter_by += " AND vehicles.odometer <= #{filters[:max_odometer]}"
      end
      if filters[:min_price]
        filter_by += " AND listings.asking_price >= #{filters[:min_price]}"
      end
      if filters[:max_price]
        filter_by += " AND listings.asking_price <= #{filters[:max_price]}"
      end
      if filters[:max_distance]
        filter_by += " AND #{distance_sql(dealership)} <= #{filters[:max_distance]}.5"
      end
      if filters[:min_year]
        minyear = filters[:min_year].to_i
        if minyear < 1990
          minyear = 1990
        end
        min_yearcode = year_to_yearcode(minyear)
        filter_by += " AND trims.yearcode >= '#{min_yearcode}'"
      end
      if filters[:max_year]
        maxyear = filters[:max_year].to_i
        if maxyear < 1990
          maxyear = 1989 # todo: this is WRONG, but it prevents a crash
        end
        max_yearcode = year_to_yearcode((maxyear + 1).to_s)
        filter_by += " AND trims.yearcode < '#{max_yearcode}'"
      end
      if filters[:must_be_certified] && filters[:must_be_certified] == true
        filter_by += " AND vehicles.certified"
      end
    end
    filter_by    
  end
  
  def self.expire_listings
    Listing.find(:all,
                 :conditions => """
                   state = 'active' AND
                   NOW() > TIMESTAMPADD(DAY,IFNULL(auction_duration,1),auction_start)
                 """).each do |listing|
      listing.expire
    end
  end

  def self.paginate(params)
    user = params[:user]
    offset = params[:offset] || '0'
    limit  = params[:page_size] || '50'
    if [:s0,:s1,:s2,:s3,:s4].all? {|s| params[s] == nil}
      params[:s4] = 'DESC'
    end
    order_by = case
      when params[:s0] : "trims.yearcode #{params[:s0]}, "
      when params[:s1] : "makes.name #{params[:s1]}, models.name #{params[:s1]}, "
      when params[:s2] : "vehicles.odometer #{params[:s2]}, "
      when params[:s3] : "listings.asking_price #{params[:s3]}, "
      when params[:s4] : "listings.updated_at #{params[:s4]}, listings.id #{params[:s4]}, "
      else ""
    end
    order_by += "trims.yearcode, makes.name, models.name, listings.id"
    Listing.find_by_sql("""
      SELECT DISTINCT listings.*
        FROM listings,
             vehicles,
             #{evd_db}.vns_trims AS trims,
             #{evd_db}.vns_models AS models,
             #{evd_db}.vns_makes AS makes,
             dealerships
       WHERE listings.vehicle_id = vehicles.id
         AND NOT listings.state IN ('draft','completed')
         AND dealerships.id = listings.dealership_id
         AND vehicles.trim_id = trims.acode
         AND trims.model_id = models.id
         AND models.make_id = makes.div_code
         AND listings.dealership_id = #{user.dealership.id}
    ORDER BY #{order_by}
       LIMIT #{offset}, #{limit}
    """)
  end

  def self.count_for_search(params)
    apply_filters(params).unwatched_by(params[:user].dealership.id).active.count
  end

  def self.paginate_for_search(params)
    offset     = params[:offset] || '0'
    limit      = params[:page_size] || '50'
    dealership = params[:user].dealership
    order_by = case
      when params[:s0] : "trims.yearcode #{params[:s0]}, "
      when params[:s1] : "makes.name #{params[:s1]}, models.name #{params[:s1]}, "
      when params[:s2] : "vehicles.odometer #{params[:s2]}, "
      when params[:s3] : "#{distance_sort_sql(dealership,params[:s3])}, "
      when params[:s4] : "listings.asking_price #{params[:s4]}, "
      else ""
    end
    
    # TODO: figure out how to combine this with apply_filters so it's only in one place'
    order_by += "trims.yearcode, makes.name, models.name, listings.id"
    # do I have a problem here with dealership being set in params?

    Listing.find_by_sql("""
      SELECT DISTINCT listings.*
        FROM listings,
             vehicles,
             #{evd_db}.vns_trims AS trims,
             #{evd_db}.vns_models AS models,
             #{evd_db}.vns_makes AS makes,
             dealerships,
             locations
       WHERE listings.dealership_id <> #{dealership.to_param}
         AND listings.state IN ('active')
         AND NOT EXISTS (SELECT *
                           FROM prospects
                          WHERE prospects.listing_id = listings.id
                            AND prospects.dealership_id = #{dealership.to_param}
                            AND NOT prospects.lost_interest)
         AND listings.vehicle_id = vehicles.id
         AND vehicles.trim_id = trims.acode
         AND trims.model_id = models.id
         AND models.make_id = makes.div_code
         AND listings.dealership_id = dealerships.id
         AND dealerships.location_id = locations.id
         #{filter_by_clause(params)}
    ORDER BY #{order_by}
       LIMIT #{offset}, #{limit}
    """)
  end

  def self.find_for_shopping_item(params)
    # this falls apart when we add make and model
    # apply_filters(params).unwatched_by(params[:user].dealership.id).active
    
    dealership = params[:user].dealership
    # do I have a problem here with dealership being set in params?

    Listing.find_by_sql("""
      SELECT DISTINCT listings.*
        FROM listings,
             vehicles,
             #{evd_db}.vns_trims AS trims,
             #{evd_db}.vns_models AS models,
             #{evd_db}.vns_makes AS makes,
             dealerships,
             locations
       WHERE listings.dealership_id <> #{dealership.to_param}
         AND listings.state IN ('active')
         AND NOT EXISTS (SELECT *
                           FROM prospects
                          WHERE prospects.listing_id = listings.id
                            AND prospects.dealership_id = #{dealership.to_param}
                            AND NOT prospects.lost_interest)
         AND listings.vehicle_id = vehicles.id
         AND vehicles.trim_id = trims.acode
         AND trims.model_id = models.id
         AND models.make_id = makes.div_code
         AND listings.dealership_id = dealerships.id
         AND dealerships.location_id = locations.id
         #{filter_by_clause(params)}
    """)
  end
  
  def validate
     errors.add_to_base "Trade rules must be accepted" unless accept_trade_rules
  end

  def accept(winning_prospect, attributes)
    prospects.reload
    prospects.each do |prospect|
      if prospect == winning_prospect
        WonEvent.create!(attributes.merge(:prospect => prospect, :amount => prospect.active_offer.amount))
      else
        LostEvent.create!(attributes.merge(:prospect => prospect, :comment => nil))
      end
    end
    self.winning_prospect = winning_prospect
    self.update_attribute(:state, 'pending')
  end

  def cancel(attributes)
    prospects.reload
    prospects.each do |prospect|
      CancelEvent.create(attributes.merge(:prospect => prospect))
    end
    self.update_attribute(:state, 'canceled')
  end

  def publish
    create_prospects_for_recipients
    match_shopping_lists
    self.update_attributes(:state => 'active', :auction_start => Clock.now)
  end

  def complete_sale
    self.update_attribute(:state, 'completed')
    vehicle.transfer_to(winning_prospect.dealership, winning_prospect.winning_amount)
  end
  
  def relist
    RelistEvent.create
    self.update_attribute(:state, 'relisted')
  end
  
  def draft_relisting(logged_in_user)
    # TODO: release validation on update to allow resetting of auction_start and trade_rules
    self.update_attributes(:state => 'draft', :created_at => Clock.now, :lister_id => logged_in_user) #, :auction_start => nil, :accept_trade_rules => 0)
  end

  def expire # called (indirectly) by cron job
    self.update_attribute(:state, 'expired')
  end

  def vehicle_name
    vehicle.display_name
  end

  def vehicle_info
    "VIN# #{vehicle.vin}, Stock# #{vehicle.stock_number}"
  end

  def vehicle_cost
    vehicle.cost
  end
  
  def active_offers
    offers.count
  end

  def vehicle_days_in_inventory
    vehicle.days_in_inventory
  end

  def observers
    if lister.nil?
      []
    else
      [lister]
    end
  end

  def auction_end
    Period.new(auction_start, auction_duration || Period::TWO_DAYS).end
  end

  def draft?
    self[:state] == 'draft'
  end

  def active?
    self[:state] == 'active'
  end

  def expired?
    self[:state] == 'expired'
  end

  def canceled?
    self[:state] == 'canceled'
  end

  def pending?
    self[:state] == 'pending'
  end

  def completed?
    self[:state] == 'completed'
  end
  
  def relisted?
    self[:state] == 'relisted'
  end

  def relistable?
    self.canceled? || self.expired?
  end
  
  def cancelable?
    self.active?
  end

  def state
    return :draft     if draft?
    return :canceled  if canceled?
    return :pending   if pending?
    return :completed if completed?
    return :relisted  if relisted?
    return :expired   if expired?
    return :unstarted if Time.now < auction_start # can't happen right now (insta-publish), other than in tests
    return :active    if !expired?
    return :expired
  end

  def high_offer
    offers.first
  end

  def auction_start
    self[:auction_start] || Clock.now
  end

  def unread_notifications?(prospect_id, recipient_id)
    notifications.unread.from_prospect(prospect_id).for_recipient(recipient_id).count > 0
  end
  
  private
  def create_prospects_for_recipients
    self.recipients.each do |recipient|
      existing_prospect = recipient.dealership.prospects.find_by_listing_id(self)
      if existing_prospect    
        existing_prospect.update_attribute(:source,'Partner')
      else
        # need all specified recipients from same dealership added to
        # observers (but multiple observers not supported yet)
        NewListingEvent.create(:originator => lister,
                               :prospect => Prospect.create(:prospector => recipient,
                                                          :dealership => recipient.dealership,
                                                          :listing    => self,
                                                          :source     => 'Partner'),
                               :comment => nil
                               )
      end
    end
  end
  
  def match_shopping_lists
    #note: this is a new listing so there should be no old prospects around
    # one prospect per dealership
    #    need all users at same dealership with a matching
    #    shopping item to be added to observers (but multiple observers
    #    not supported yet)
    ShoppingItem.find_shoppers(self).each do |shopper|
      theProspect = Prospect.create(:prospector => shopper.originator,
                                    :dealership => shopper.dealership,
                                    :listing    => self,
                                    :source     => 'Shopping List')
      ShoppingItemEvent.create(:originator => shopper.originator,
                               :prospect => theProspect,
                               :comment => "shopping list match for new listing"
                               )
    end
  end

end
