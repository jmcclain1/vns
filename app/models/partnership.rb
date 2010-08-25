# == Schema Information
# Schema version: 52
#
# Table name: partnerships
#
#  id          :integer(11)     not null, primary key
#  created_at  :datetime        
#  updated_at  :datetime        
#  inviter_id  :integer(11)     
#  receiver_id :integer(11)     
#  accepted    :boolean(1)      
#

class Partnership < ActiveRecord::Base
  belongs_to :inviter,
             :class_name => 'User',
             :foreign_key => 'inviter_id'
  belongs_to :receiver,
             :class_name => 'User',
             :foreign_key => 'receiver_id'

  validates_each :receiver do |record, attr, value|
    record.errors.add attr, 'cannot be the same as inviter' if value == record.inviter
  end
  validates_uniqueness_of :receiver_id,
                          :scope => :inviter_id

  def self.paginate(params)
    user = params[:user]
    offset = params[:offset] || '0'
    limit  = params[:page_size] || '50'
    order_by = case
      when params[:s0] : "CONCAT(profiles.first_name, profiles.last_name) #{params[:s0]},"
      when params[:s1] : "users.unique_name #{params[:s1]},"
      when params[:s2] : "#{distance_sort_sql(user.dealership,params[:s2])},"
      when params[:s3] : "users.status #{params[:s3]},"
      else               ""
    end
    order_by += "partnerships.id"
    partner_sql = <<-SQL
      SELECT users.*
      FROM   users, profiles, partnerships, dealerships, locations
      WHERE  profiles.id = users.id AND
             ((partnerships.inviter_id = #{user.id} AND partnerships.receiver_id = users.id) OR
              partnerships.receiver_id = #{user.id} AND partnerships.inviter_id = users.id AND partnerships.accepted)
             AND dealerships.id = users.dealership_id
             AND dealerships.location_id = locations.id
      order by #{order_by}
      limit #{offset}, #{limit}
    SQL

    User.find_by_sql(partner_sql)
  end
end
