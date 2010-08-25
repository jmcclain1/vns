class AddUserToDealershipRelationship < ActiveRecord::Migration
  def self.up
    add_column :users, :dealership_id, :integer
  end

  def self.down
    drop_column :users, :dealership_id
  end
end
