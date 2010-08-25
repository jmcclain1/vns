class AddShoppingItems < ActiveRecord::Migration
  def self.up
    create_table :shopping_items do |t|
      t.column :created_at,    :datetime
      t.column :updated_at,    :datetime
      t.column :dealership_id, :integer # a Dealership
      t.column :originator_id, :integer # a User
      t.column :priority,      :boolean, :default => false
      t.column :min_year,      :integer
      t.column :max_year,      :integer
      t.column :make_id,       :string
      t.column :model_id,      :integer
      t.column :min_odometer,  :integer
      t.column :max_odometer,  :integer
      t.column :min_price,     :integer
      t.column :max_price,     :integer
      t.column :max_distance,  :integer
      t.column :must_be_certified,  :boolean, :default => false
    end
  end

  def self.down
    drop_table :shopping_items
  end
end
