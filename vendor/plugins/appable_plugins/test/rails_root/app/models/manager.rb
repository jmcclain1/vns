class Manager < ActiveRecord::Base
  def self.in_manager?
    true
  end
end