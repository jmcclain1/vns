class Actor < ActiveRecord::Base
  @@load_order << :actor
  
  def self.in_actor?
    true
  end
end