class AddDealerships < ActiveRecord::Migration
  def self.up
    create_table :dealerships do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :dealerships
  end
end
