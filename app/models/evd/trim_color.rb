# == Schema Information
# Schema version: 52
#
# Table name: vns_colors
#
#  id         :string(35)      default(""), not null, primary key
#  option_id  :string(20)      default(""), not null
#  name       :string(200)     
#  rgb        :string(500)     
#  acode      :string(13)      default(""), not null
#  paint_type :string(25)      
#

class Evd::TrimColor < Evd
  set_table_name 'vns_colors'
  
  def hex
    r = "%02x" % r_code
    g = "%02x" % g_code
    b = "%02x" % b_code
    r+g+b
  end

  def exterior?
    parse_rgb[:type] == 'Primary'
  end

  def r_code
    parse_rgb[:red].to_i
  end

  def g_code
    parse_rgb[:green].to_i
  end

  def b_code
    parse_rgb[:blue].to_i
  end

  def generic_name
    parse_rgb[:genericclr]
  end

  def name
    self['name'].gsub(/^\(.\s.\)\s/, '')
  end

  private
  def parse_rgb
    string_tuples = self.rgb.split(/\s(?=[A-Z]*=)/)
    hash_tuples = string_tuples.inject({}) do |sum, tuple|
      key, value = tuple.split('=')
      sum[key.downcase.to_sym] = value
      sum
    end
    return hash_tuples
  end
end
