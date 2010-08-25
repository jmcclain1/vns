class Actor < ActiveRecord::Base
  @@load_order = [:actor_skeleton]
  cattr_accessor :load_order
  
  def self.in_actor_skeleton?
    true
  end
end