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

class AskEvent < Event
  after_create :send_sms_to_seller

  validates_presence_of :comment

  def description_for_seller
    "Message Received"
  end

  def description_for_buyer
    "Message Sent"
  end

  def send_sms_to_seller
    self.prospect.listing.observers.each do |seller|
      if seller.sms_receive_inquiry
        NotificationMailer.deliver_ask(self, :to => seller.sms_address)
      end
    end
  end

end
