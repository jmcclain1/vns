# == Schema Information
# Schema version: 52
#
# Table name: vns_makes
#
#  div_code :string(2)       default(""), not null, primary key
#  name     :string(50)      
#  mfguid   :integer(10)     not null
#

class Evd::Make < Evd

  ANY = "any_make"

  set_table_name 'vns_makes'
  set_primary_key "div_code"

  has_many :models

  def self.all
    find(:all, :order => 'name')
  end
end
