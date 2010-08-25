module EmailHelper
  def offer_received_body(offer)
    "Vehicle: #{offer.prospect.listing.vehicle.display_name}\n" +
    "Offer: #{offer.amount.to_currency}"
  end

  def listing_expired_body(listing)
    "Expired: #{listing.vehicle.display_name}"
  end

  def ask_body(ask)
    "Vehicle: #{ask.prospect.listing.vehicle.display_name}\n" +
    "Question: #{ask.comment}"
  end
  
  def reply_body(reply)
    "Vehicle: #{reply.prospect.listing.vehicle.display_name}\n" +
    "Reply: #{reply.comment}"
  end
  
  def won_body(won)
    "Vehicle: #{won.prospect.listing.vehicle.display_name}\n"
  end
  
  def lost_body(lost)
    "Vehicle: #{lost.prospect.listing.vehicle.display_name}\n"
  end
  
  def cancel_body(cancel)
    "Vehicle: #{cancel.prospect.listing.vehicle.display_name}\n"
  end
end
