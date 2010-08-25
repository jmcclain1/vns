class AddEventToNotifications < ActiveRecord::Migration
  def self.up
    add_column :notifications, :event_id, :integer, :default => 0
  end

  def self.down
    remove_column :notifications, :event_id
  end
end
