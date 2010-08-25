# == Schema Information
# Schema version: 52
#
# Table name: locations
#
#  id          :integer(11)     not null, primary key
#  address     :string(255)     
#  city        :string(255)     
#  region      :string(255)     
#  postal_code :string(255)     
#  country     :string(255)     
#  latitude    :float           
#  longitude   :float           
#  created_at  :datetime        
#  located_at  :datetime        
#  located_by  :string(255)     
#  accuracy    :string(255)     
#

class Location < ActiveRecord::Base
  def display_name
    "#{self.address}, #{self.city} #{self.region}"
  end
end
