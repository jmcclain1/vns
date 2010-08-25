# == Schema Information
# Schema version: 52
#
# Table name: vns_modelyears
#
#  id        :integer(10)     not null
#  model_id  :integer(10)     not null
#  year_code :string(3)       default(""), not null
#  acode     :string(13)      default(""), not null
#

class Evd::Modelyear < Evd
  set_table_name 'vns_modelyears'
  set_primary_key 'modelid'

  belongs_to :model
  belongs_to :trim,
             :foreign_key => 'acode'
end
