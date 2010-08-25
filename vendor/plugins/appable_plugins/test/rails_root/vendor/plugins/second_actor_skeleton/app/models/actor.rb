class Actor < ActiveRecord::Base
  @@load_order << :second_actor_skeleton
  
  def self.in_second_actor_skeleton?
    true
  end
end