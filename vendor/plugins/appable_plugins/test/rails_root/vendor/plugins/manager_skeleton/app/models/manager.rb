class Manager < ActiveRecord::Base
  def self.in_manager_skeleton?
    true
  end
end