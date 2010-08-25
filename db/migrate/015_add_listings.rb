class AddListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.column :dealership_id, :integer, :null => false
      t.column :vehicle_id, :integer, :null => false
      t.column :asking_price, :decimal, :precision => 11, :scale => 2, :null => false

      t.column :lister_id, :integer
      t.column :comments, :text

      t.column :auction_duration, :integer
      t.column :auction_start, :datetime
      t.column :inspection_duration, :integer
      t.column :accept_trade_rules, :boolean, :null => false, :default => false
      t.column :draft, :boolean, :default => true      
    end
  end

  def self.down
    drop_table :listings
  end
end
