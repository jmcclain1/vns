class AddLostInterestToProspect < ActiveRecord::Migration
  def self.up
    add_column    :prospects, :lost_interest, :boolean, :default => false
  end

  def self.down
    remove_column    :prospects, :lost_interest
  end
end
