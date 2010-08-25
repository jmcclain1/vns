class AddTermsOfService < ActiveRecord::Migration
  def self.up
    create_table "terms_of_services" do |t|
      t.column "text", :string
      t.column "revision", :integer
      t.column "created_at", :datetime
    end
    execute "INSERT INTO terms_of_services (id, text, revision, created_at) VALUES (1, 'Default Terms Of Service Text', 1, NOW())"
    
    add_column :users, :terms_of_service_id, :integer, :null => false
    update "update users set terms_of_service_id = 1"
  end

  def self.down
    drop_table "terms_of_services"

    remove_column :users, :terms_of_service_id
  end
end


