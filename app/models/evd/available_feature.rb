# == Schema Information
# Schema version: 52
#
# Table name: vns_features
#
#  id           :string(35)      default(""), not null, primary key
#  acode        :string(13)      default(""), not null
#  availability :string(1)       
#  name         :string(200)     
#  option_id    :string(20)      default(""), not null
#  cluster_id   :integer(10)     not null
#  ecc          :string(4)       
#  engine       :integer(1)      
#  transmission :integer(1)      
#  standard     :integer(1)      
#  optional     :integer(1)      
#  ecc_category :string(100)     
#

class Evd::AvailableFeature < Evd
  set_table_name 'vns_features'  
end
