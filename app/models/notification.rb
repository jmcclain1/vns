# == Schema Information
# Schema version: 52
#
# Table name: notifications
#
#  id             :integer(11)     not null, primary key
#  recipient_id   :integer(11)     
#  tradeable_type :string(255)     
#  tradeable_id   :integer(11)     
#  alerted        :boolean(1)      default(TRUE)
#  unread         :boolean(1)      default(TRUE)
#  event_id       :integer(11)     default(0)
#


class Notification < ActiveRecord::Base
  belongs_to :recipient, :class_name => 'User', :foreign_key => :recipient_id
  belongs_to :tradeable, :polymorphic => true
  belongs_to :event
  
  validates_presence_of :recipient
  validates_presence_of :tradeable
  validates_presence_of :event

  has_finder :alerted, :conditions => "notifications.alerted"
  has_finder :unread,  :conditions => "notifications.unread"
  has_finder :active,  :conditions => "(notifications.alerted OR notifications.unread)"
  has_finder :message, :conditions => "events.type <> 'OfferEvent'", :include => :event
  has_finder :offer,   :conditions => "events.type = 'OfferEvent'", :include => :event
  
  has_finder :as_buyer,  :conditions => {:tradeable_type => 'Prospect'} do
    def prospects
      tradeables
    end
  end
  has_finder :as_seller, :conditions => {:tradeable_type => 'Listing'} do
    def listings
      tradeables
    end
  end

  has_finder :for_prospect, lambda { |prospect|
    { :conditions => {:tradeable_type => 'Prospect', :tradeable_id => prospect.id} }
  }
  has_finder :for_listing,  lambda { |listing|
    { :conditions => {:tradeable_type => 'Listing',  :tradeable_id => listing.id} }  
  }

  has_finder :for_recipient, lambda {|recipient| {:conditions => {:recipient_id => recipient.id}}}

  has_finder :from_prospect, lambda { |prospect_id|
    { :include => :event,
      :conditions => ["tradeable_type = 'Listing' AND events.prospect_id = ?",prospect_id] }
  }
  
  def originator
    event.originator
  end

  def self.tradeables
    find(:all).collect{|notification| notification.tradeable}.uniq
  end

  def clear_alerted
    self.update_attribute(:alerted, false)
  end

  def clear_unread
    self.update_attributes(:unread => false, :alerted => false)
  end
end
