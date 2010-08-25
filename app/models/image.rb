# == Schema Information
# Schema version: 52
#
# Table name: images
#
#  id           :integer(11)     not null, primary key
#  created_at   :datetime        
#  updated_at   :datetime        
#  vehicle_id   :integer(11)     
#  pivotal      :boolean(1)      
#  parent_id    :integer(11)     
#  content_type :string(255)     
#  filename     :string(255)     
#  thumbnail    :string(255)     
#  size         :integer(11)     
#  width        :integer(11)     
#  height       :integer(11)     
#

class Image < ActiveRecord::Base
  belongs_to :vehicle

  validates_uniqueness_of :pivotal,
                          :scope => "vehicle_id",
                          :if => lambda {|i| !i.pivotal.blank?},
                          :message => "Only one image per vehicle can be the pivotal (default) image"

  has_attachment :content_type => :image,
                 :storage => :file_system,
                 :max_size => 1.megabytes,
                 :thumbnails => { :thumb => '80x80>' }
end
