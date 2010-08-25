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

class ReplyEvent < Event
  after_create :send_sms_to_buyer

  validates_presence_of :comment

  def description_for_seller
    "Message Sent"
  end

  def description_for_buyer
    "Message Received"
  end

 def send_sms_to_buyer
    self.prospect.observers.each do |buyer|
      if buyer.sms_receive_reply
        NotificationMailer.deliver_reply(self, :to => buyer.sms_address)
      end
    end
  end

end
