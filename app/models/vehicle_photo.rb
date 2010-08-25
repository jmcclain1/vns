# == Schema Information
# Schema version: 52
#
# Table name: assets
#
#  id                :integer(11)     not null, primary key
#  type              :text            
#  created_at        :datetime        
#  updated_at        :datetime        
#  position          :integer(11)     
#  creator_id        :integer(11)     
#  source_uri        :string(255)     
#  original_filename :string(255)     
#

class VehiclePhoto < Photo
  has_versions :small => Asset::Command::Photo::ResizedAndCropped.new(60, 45, Magick::CenterGravity),
               :large => Asset::Command::Photo::ResizedAndCropped.new(280, 210, Magick::CenterGravity),
               :fullsize => Asset::Command::Photo::ResizedAndCropped.new(562, 421, Magick::CenterGravity)
end
