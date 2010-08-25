class DestroyInventoryItem < ActiveRecord::Migration
  def self.up
    # note: we are not migrating the data here, so you must blow away and recreate your db
    drop_table :inventory_items

    add_column :vehicles, "dealership_id",     :integer
    add_column :vehicles, "title",             :boolean,                                                :default => false
    add_column :vehicles, "title_state",       :string,   :limit => 2
    add_column :vehicles, "stock_number",      :string,   :limit => 100
    add_column :vehicles, "location",          :string,   :limit => 100
    add_column :vehicles, "actual_cash_value", :decimal,                 :precision => 10, :scale => 2
    add_column :vehicles, "cost",              :decimal,                 :precision => 10, :scale => 2
    add_column :vehicles, "comments",          :text
    add_column :vehicles, "draft",             :boolean,                                                :default => true

#    rename_column :listings, :inventory_item_id, :vehicle_id
  end

  def self.down
    raise IrreversibleMigrationError
  end
end
