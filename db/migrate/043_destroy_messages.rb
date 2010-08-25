class DestroyMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages
  end

  def self.down
    create_table :messages do |t|
      t.column :type, :string
      t.column :sender_id, :integer
      t.column :receiver_id, :integer
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :seen, :boolean, :default => false
      t.column :parent_id, :integer

      # Inquiry Message
      t.column :listing_id, :integer
    end
  end
end
