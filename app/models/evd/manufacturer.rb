# == Schema Information
# Schema version: 52
#
# Table name: vns_manufacturers
#
#  id   :integer(10)     not null, primary key
#  name :string(50)      
#

class Evd::Manufacturer < Evd
  set_table_name 'vns_manufacturers'

  has_many :models
end
