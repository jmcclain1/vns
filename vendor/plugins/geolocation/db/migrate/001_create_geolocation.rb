class CreateGeolocation < ActiveRecord::Migration

  def self.up
    create_table "locations", :force => true do |t|
      t.column "address", :string
      t.column "city", :string
      t.column "region", :string
      t.column "postal_code", :string
      t.column "country", :string
      t.column "latitude",          :float
      t.column "longitude",         :float
      t.column "created_at", :datetime
      t.column "located_at", :datetime
      t.column "located_by", :string
      t.column "accuracy", :string
    end

    if RAILS_ENV == "test"
      create_table "cats", :force => true do |t|
        t.column "name", :string
        t.column "location_id", :integer
      end
      create_table "dogs", :force => true do |t|
        t.column "name", :string
        t.column "location_id", :integer
      end
    end

  end

  def self.down
    if RAILS_ENV == "test"
      drop_table :dogs
      drop_table :cats
    end
    drop_table :locations
  end
end