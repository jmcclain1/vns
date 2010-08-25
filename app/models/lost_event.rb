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

class LostEvent < Event
  after_create :send_sms_to_buyer

  def description_for_seller
    "Offer Accepted"
  end

  def description_for_buyer
    "Auction Closed"
  end

 def send_sms_to_buyer
    self.prospect.observers.each do |buyer|
      if buyer.sms_receive_auction_lost
        NotificationMailer.deliver_lost(self, :to => buyer.sms_address)
      end
    end
  end

end
