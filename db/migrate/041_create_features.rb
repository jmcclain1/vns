class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.column :vehicle_id, :integer
      t.column :name, :string
      t.column :evd_feature_id, :string
      t.column :evd_ecc, :string
      t.column :engine, :boolean
      t.column :transmission, :boolean

      t.column :created_at,    :datetime
      t.column :updated_at,    :datetime
    end
  end

  def self.down
    drop_table :features
  end
end
