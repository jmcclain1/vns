# == Schema Information
# Schema version: 52
#
# Table name: users
#
#  id                        :integer(11)     not null, primary key
#  email_address             :string(255)     
#  encrypted_password        :string(255)     
#  created_at                :datetime        
#  updated_at                :datetime        
#  unique_name               :string(255)     
#  account_validated         :boolean(1)      
#  salt                      :string(255)     
#  super_admin               :boolean(1)      
#  terms_of_service_id       :integer(11)     
#  dealership_id             :integer(11)     
#  status                    :string(255)     default("inactive")
#  sms_address               :string(255)     
#  sms_wants_any_sms         :boolean(1)      default(TRUE)
#  sms_wants_new_offer       :boolean(1)      
#  sms_wants_listing_expired :boolean(1)      
#  sms_wants_inquiry         :boolean(1)      
#  sms_wants_reply           :boolean(1)      
#  sms_wants_auction_won     :boolean(1)      
#  sms_wants_auction_lost    :boolean(1)      
#  sms_wants_auction_cancel  :boolean(1)      
#

class User < ActiveRecord::Base
  belongs_to :dealership

  validates_inclusion_of :status,
                         :in => %w(inactive active expired)

  validates_format_of :sms_address,
                      :with => /(^([\d]{10})@((?:[-a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i,
                      :message => "The SMS address you provided is not valid".customize

  has_many :partnerships_as_inviter,
           :class_name => 'Partnership',
           :foreign_key => 'inviter_id'
  has_many :partnerships_as_receiver,
           :class_name => 'Partnership',
           :foreign_key => 'receiver_id'
  has_many :partners_as_inviter,
           :through => :partnerships_as_inviter,
           :source => :receiver
  has_many :partners_as_receiver,
           :through => :partnerships_as_receiver,
           :source => :inviter,
           :conditions => "partnerships.accepted"

  has_many :listings,  :foreign_key => :lister_id, :conditions => "state <> 'draft'", :order => "listings.updated_at DESC, listings.id"
  has_many :prospects, :foreign_key => :prospector_id, :order => "prospects.updated_at DESC, prospects.id"
  has_many :notifications, :foreign_key => :recipient_id
  has_many :events_as_originator, :class_name => 'Event', :foreign_key => :originator_id
  has_many :shopping_items, :foreign_key => :originator_id

  attr_accessible :sms_wants_any_sms
  attr_accessible :sms_address
  attr_accessible :sms_wants_new_offer
  attr_accessible :sms_wants_listing_expired
  attr_accessible :sms_wants_inquiry
  attr_accessible :sms_wants_reply
  attr_accessible :sms_wants_auction_won
  attr_accessible :sms_wants_auction_lost
  attr_accessible :sms_wants_auction_cancel
  
  def count_for_buying_tab
    dealership.count_for_buying_tab
  end

  def count_for_selling_tab
    dealership.count_for_selling_tab
  end
  
  def prospects_with_alerted_notifications
    notifications.alerted.as_buyer.prospects
  end

  def listings_with_alerted_notifications
    notifications.alerted.as_seller.listings
  end

  # workaround until the user plugin supports disabled TOS by default
  def needs_to_accept_tos?
    false
  end

  def partners
    self.partners_as_inviter + self.partners_as_receiver
  end

  def location
    self.dealership ? self.dealership.location : nil
  end

  def distance_from(other_user)
    self.location.distance_from(other_user.location)
  end

  def sms_receive_new_offer
    sms_wants_any_sms && sms_wants_new_offer && sms_address_valid?
#    read_attribute("sms_receive_new_offer") && sms_address_valid?
  end

  def sms_receive_listing_expired
    sms_wants_any_sms && sms_wants_listing_expired && sms_address_valid?
#    read_attribute("sms_receive_listing_expired") && sms_address_valid?
  end

  def sms_receive_inquiry
    sms_wants_any_sms && sms_wants_inquiry && sms_address_valid?
  end
  
  def sms_receive_reply
    sms_wants_any_sms && :sms_wants_reply && sms_address_valid?
  end
  
  def sms_receive_auction_won
    sms_wants_any_sms && :sms_wants_auction_won && sms_address_valid?
  end
  
  def sms_receive_auction_lost
    sms_wants_any_sms && :sms_wants_auction_lost && sms_address_valid?
  end
  
  def sms_receive_auction_cancel
    sms_wants_any_sms && :sms_wants_auction_cancel && sms_address_valid?
  end
  
  private

  def sms_address_valid?
    sms_address && !sms_address.empty?
  end
end
