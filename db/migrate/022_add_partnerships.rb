class AddPartnerships < ActiveRecord::Migration
  def self.up
    create_table :partnerships do |t|
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      
      t.column :inviter_id, :integer
      t.column :receiver_id, :integer
      t.column :accepted, :boolean, :default => false
    end
  end

  def self.down
    drop_table :partnerships
  end
end
