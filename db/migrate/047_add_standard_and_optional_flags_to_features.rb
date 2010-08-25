class AddStandardAndOptionalFlagsToFeatures < ActiveRecord::Migration
  def self.up
    add_column :features, :standard, :boolean
    add_column :features, :optional, :boolean
  end

  def self.down
    remove_column :features, :standard
    remove_column :features, :optional
  end
end
