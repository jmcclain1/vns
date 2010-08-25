class AddImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime

      t.column :vehicle_id, :integer
      t.column :pivotal, :boolean, :default => false

      t.column :parent_id,  :integer
      t.column :content_type, :string
      t.column :filename, :string
      t.column :thumbnail, :string
      t.column :size, :integer
      t.column :width, :integer
      t.column :height, :integer
    end
  end

  def self.down
    drop_table :images
  end
end
