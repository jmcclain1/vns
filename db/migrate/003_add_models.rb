class AddModels < ActiveRecord::Migration

  def self.up
    create_table :models do |t|
      t.column :ad_model_id, :integer, :null => false
      t.column :year, :integer, :null => false
      t.column :name, :string, :null => false
    end
  end

  def self.down
    drop_table :models
  end
end
