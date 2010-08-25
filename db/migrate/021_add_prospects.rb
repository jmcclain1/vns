class AddProspects < ActiveRecord::Migration
  def self.up
    create_table :prospects do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :listing_id, :integer
      t.column :dealership_id, :integer
      t.column :prospector_id, :integer
    end
  end

  def self.down
    drop_table :prospects
  end
end
