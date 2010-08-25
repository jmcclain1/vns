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

class ShoppingItemEvent < Event
  after_create :send_sms_to_buyer

  def description_for_seller  # for selling inbox
    ""
  end

  def description_for_buyer
    "Shopping list match"
  end

  def send_sms_to_buyer
  end

  private
  def create_notifications
    # buyer notification includes originator of shopping item / prospect
    self.prospect.dealership.traders.each do |buyer|
      Notification.create(:recipient => buyer,  :tradeable => self.prospect, :alerted => self.prospect.observers.include?(buyer), :event => self)
    end
    # no seller notification
  end

end
