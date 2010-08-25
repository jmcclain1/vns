class AddLocationToDealerships < ActiveRecord::Migration
  def self.up
    add_column :dealerships, :location_id, :integer
  end

  def self.down
    remove_column :dealerships, :location_id
  end
end
