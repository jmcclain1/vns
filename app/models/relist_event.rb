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

class RelistEvent < Event

  def description_for_seller
    "Relisted"
  end

end
