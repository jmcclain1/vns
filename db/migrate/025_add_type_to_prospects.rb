class AddTypeToProspects < ActiveRecord::Migration
  def self.up
    add_column :prospects, :type, :string
  end

  def self.down
    remove_column :prospects, :type
  end
end
