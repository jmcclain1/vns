# == Schema Information
# Schema version: 52
#
# Table name: vns_models
#
#  id              :integer(10)     not null, primary key
#  name            :string(50)      
#  make_id         :string(2)       default(""), not null
#  manufacturer_id :integer(10)     not null
#

class Evd::Model < Evd

  ANY = 0
  
  set_table_name 'vns_models'

  belongs_to :manufacturer
  belongs_to :make
  has_many :modelyears
  has_many :trims,
           :through => :modelyears
end
