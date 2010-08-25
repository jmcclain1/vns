class AddEventsAndNotifications < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :type, :string # STI
      t.column :originator_id, :integer # a User
      t.column :prospect_id, :integer # a Prospect
      t.column :comment, :text
      t.column :amount, :decimal, :precision => 10, :scale => 2
      # t.column :parent_id, :integer # an Event
    end
    create_table :notifications do |t|
      t.column :recipient_id, :integer # a User
      t.column :tradeable_type, :string # either a 'Listing' or a 'Prospect'
      t.column :tradeable_id,   :integer
      t.column :alerted, :boolean, :default => true
      t.column :unread,  :boolean, :default => true
    end
  end

  def self.down
    drop_table :notifications
    drop_table :events
  end
end
