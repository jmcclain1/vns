class RemoveNotNullConstraintFromListingFields < ActiveRecord::Migration
  def self.up
    change_column :listings, :asking_price, :decimal, :precision => 11, :scale => 2, :null => true, :default => nil
    change_column :listings, :vehicle_id, :integer, :null => true, :default => nil
  end

  def self.down
    change_column :listings, :asking_price, :decimal, :precision => 11, :scale => 2, :null => false
    change_column :listings, :vehicle_id, :integer, :null => false
  end
end
