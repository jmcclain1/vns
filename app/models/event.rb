# == Schema Information
# Schema version: 52
#
# Table name: events
#
#  id            :integer(11)     not null, primary key
#  created_at    :datetime        
#  updated_at    :datetime        
#  type          :string(255)     
#  originator_id :integer(11)     
#  prospect_id   :integer(11)     
#  comment       :text            
#  amount        :decimal(10, 2)  
#

class Event < ActiveRecord::Base
  after_create :create_notifications
  after_save   :update_last_activity
  
  belongs_to :prospect
  belongs_to :originator, :class_name => 'User', :foreign_key => :originator_id

  validates_presence_of :prospect
  validates_presence_of :originator
  
  has_many :notifications

  def sender_name
    self.originator.full_name
  end

  def description_for_seller
    self.class.to_s
  end

  def description_for_buyer
    self.class.to_s
  end

  private
  def create_notifications
    self.prospect.dealership.traders.each do |buyer|
      Notification.create(:recipient => buyer,  :tradeable => self.prospect, :alerted => self.prospect.observers.include?(buyer), :event => self) unless buyer == self.originator
    end
    self.prospect.listing.dealership.traders.each do |seller|
      Notification.create(:recipient => seller, :tradeable => self.prospect.listing, :alerted => self.prospect.listing.observers.include?(seller), :event => self) unless seller == self.originator
    end
  end

  def update_last_activity
    self.prospect.update_attributes(:last_activity => self.updated_at, :lost_interest => 0)
    self.prospect.listing.update_attribute(:last_activity, self.updated_at)
  end
end
