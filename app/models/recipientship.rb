# == Schema Information
# Schema version: 52
#
# Table name: recipientships
#
#  id         :integer(11)     not null, primary key
#  user_id    :integer(11)     
#  listing_id :integer(11)     
#  updated_at :datetime        
#

class Recipientship < ActiveRecord::Base
  belongs_to :recipient, :class_name => "User", :foreign_key => "user_id"
  belongs_to :listing
end
