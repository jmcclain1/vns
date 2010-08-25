class AddLocationCaching < ActiveRecord::Migration

  def self.up
    create_table "location_caches", :force => true do |t|
      t.column "location_string", :string
      t.column "created_at", :datetime
      t.column "location_id", :integer
    end
  end

  def self.down
    drop_table :location_caches
  end
end