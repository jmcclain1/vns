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

class OfferEvent < Event
  after_create :send_sms_to_seller

  validates_each :amount do |model,attr,value|
    if value.blank?
      model.errors.add(attr, "Offer amount can't be blank")
    elsif value <= BigDecimal('0')
      model.errors.add(attr, "Offer amount must be a number")
    elsif model.prospect
      current_offer = model.prospect.active_offer
      if current_offer && current_offer.amount > value
        model.errors.add(attr, "Improved offer amount can't be less than current offer amount of #{current_offer.amount.to_currency}")
      end
    end
  end
  
  def description_for_seller
    "Offer Received"
  end

  def description_for_buyer
    "Offer Made"
  end

  def send_sms_to_seller
    self.prospect.listing.observers.each do |seller|
      if seller.sms_receive_new_offer
        NotificationMailer.deliver_offer_received(self, :to => seller.sms_address)
      end
    end
  end

end
