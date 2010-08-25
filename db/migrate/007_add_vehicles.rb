class AddVehicles < ActiveRecord::Migration
  def self.up
    create_table :vehicles do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.column :vin, :string, :limit => 17

      t.column :trim_id, :string

      t.column :exterior_color_id, :string
      t.column :interior_color_id, :string

      t.column :certified, :boolean, :default => false
      t.column :odometer, :decimal, :precision => 10, :scale => 1
      t.column :frame_damage, :boolean, :default => false
      t.column :prior_paint, :boolean, :default => false
    end

  end

  def self.down
    drop_table :vehicles
  end
end
