class AddRecipientshipsTable < ActiveRecord::Migration
  def self.up
    create_table :recipientships do |t|
      t.column :user_id, :integer
      t.column :listing_id, :integer
      t.column :updated_at, :datetime
    end

    add_index :recipientships, :user_id
    add_index :recipientships, :listing_id
    add_index :recipientships, :updated_at
  end

  def self.down
    drop_table :recipientships
  end
end
