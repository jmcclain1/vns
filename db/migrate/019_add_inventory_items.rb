class AddInventoryItems < ActiveRecord::Migration
  def self.up
    create_table :inventory_items do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.column :vehicle_id, :integer
      t.column :dealership_id, :integer

      t.column :title, :boolean, :default => false
      t.column :title_state, :string, :limit => 2
      t.column :stock_number, :string, :limit => 100
      t.column :location, :string, :limit => 100
      t.column :actual_cash_value, :decimal, :precision => 10, :scale => 2
      t.column :cost, :decimal, :precision => 10, :scale => 2
      t.column :comments, :text

      t.column :draft, :boolean, :default => true
    end
  end

  def self.down
    drop_table :inventory_items
  end
end
