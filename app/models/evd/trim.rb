# == Schema Information
# Schema version: 52
#
# Table name: evd_ii.vns_trims
#
#  acode     :string(13)      default(""), not null, primary key
#  doors     :integer(10)     
#  wheelbase :string(50)      
#  GVWR      :integer(10)     
#  drive     :string(50)      
#  body      :string(50)      
#  trim      :string(100)     
#  model_id  :integer(10)     
#  yearcode  :string(3)       default(""), not null
#

# == Schema Information
# Schema version: 51
#
# Table name: vns_trims
#
#  acode     :string(13)      default(""), not null, primary key
#  doors     :integer(10)     
#  wheelbase :string(50)      
#  GVWR      :integer(10)     
#  drive     :string(50)      
#  body      :string(50)      
#  trim      :string(100)     
#  model_id  :integer(10)     
#  yearcode  :string(3)       default(""), not null
#

class Evd::Trim < Evd
  set_table_name "#{evd_db}.vns_trims"
  set_primary_key "acode"

  has_many :exterior_colors,
           :class_name => 'TrimColor',
           :conditions => 'paint_type = "Primary"',
           :foreign_key => 'acode'
  has_many :interior_colors,
           :class_name => 'TrimColor',
           :conditions => 'paint_type = "Interior"',
           :foreign_key => 'acode'
  has_many :available_features,
           :class_name => 'AvailableFeature',
           :foreign_key => 'acode'
  has_and_belongs_to_many :squish_vins,
                          :join_table => 'vns_squish_vins_acodes',
                          :foreign_key => 'acode',
                          :association_foreign_key => 'squish_vin'
  belongs_to :model

  def self.find_all_by_vin(vin)
    squish_vin = Evd::SquishVin.squish(vin)
    vin_entry = Evd::SquishVin.find_by_squish_vin(squish_vin)
    vin_entry.nil? ? [] : vin_entry.trims
  end

  def year
    decade_hash = { 'A' => 1990, 'B' => 2000, 'C' => 2010, 'D' => 2020 }
    decade_hash[self.yearcode[0,1]] + self.yearcode[1,1].to_i
  end

#  def standard_transmission
#    t = Transmission.find_by_sql("SELECT transmissions.* FROM transmissions, clutches, styles WHERE clutches.standard AND clutches.style_id = #{self.id} AND clutches.transmission_id = transmissions.id")
#    t.first
#  end
#
#  def standard_engine
#    t = Engine.find_by_sql("SELECT engines.* FROM engines, motorizations, styles WHERE motorizations.standard AND motorizations.style_id = #{self.id} AND motorizations.engine_id = engines.id")
#    t.first
#  end
#
  def characterization
    "#{self.year} #{self.model.make.name} #{self.model.name} #{self.trim}"
  end
#
#  def self.lookup(vin_string)
#    vin = Vin.find_by_vin(vin_string)
#    if vin.nil?
#      []
#    else
#      vin.styles
#    end
#  end
end
