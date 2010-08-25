# == Schema Information
# Schema version: 52
#
# Table name: vns_squish_vins
#
#  squish_vin :string(10)      default(""), not null, primary key
#  acode      :string(13)      default(""), not null
#

class Evd::SquishVin < Evd
  set_table_name 'vns_squish_vins'
  set_primary_key "squish_vin"

  has_and_belongs_to_many :trims,
                          :join_table => 'vns_squish_vins_acodes',
                          :foreign_key => 'squish_vin',
                          :association_foreign_key => 'acode'

  def self.squish(vin)
    vin[0,8] + vin[9,2] # digits 1-8 and 10-11
  end
end
