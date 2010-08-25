# == Schema Information
# Schema version: 52
#
# Table name: features
#
#  id             :integer(11)     not null, primary key
#  vehicle_id     :integer(11)     
#  name           :string(255)     
#  evd_feature_id :string(255)     
#  evd_ecc        :string(255)     
#  engine         :boolean(1)      
#  transmission   :boolean(1)      
#  created_at     :datetime        
#  updated_at     :datetime        
#  standard       :boolean(1)      
#  optional       :boolean(1)      
#

class Feature < ActiveRecord::Base
  belongs_to :vehicle
  
end
