class InitialUserPluginSchema < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column "password_reset_token", :string
      t.column "password_reset_expiration", :datetime
      t.column "email_address", :string
      t.column "encrypted_password", :string
      t.column "first_name", :string
      t.column "last_name", :string
      t.column "date_of_birth", :datetime
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "last_login", :datetime
      t.column "unique_name", :string
    end

    add_index(:users, [:unique_name], :unique => true)
    add_index(:users, [:email_address], :unique => true)

    create_table "auto_logins", :force => true do |t|
      t.column "token", :string
      t.column "user_id", :integer
    end
  end

  def self.down
    drop_table :users
  end
end
