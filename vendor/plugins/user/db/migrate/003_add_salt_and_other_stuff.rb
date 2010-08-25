class AddSaltAndOtherStuff < ActiveRecord::Migration
  def self.up
    add_column(:users, :salt, :string)
    remove_column(:users, :last_login)
    remove_column(:users, :password_reset_token)
    remove_column(:users, :password_reset_expiration)

    create_table(:user_activities) do |t|
      t.column(:user_id, :integer)
      t.column(:type, :string)
      t.column(:created_at, :datetime)
    end

    create_table(:tokens) do |t|
      t.column(:user_id, :integer)
      t.column(:type, :string)
      t.column(:token, :string)
      t.column(:expires_at, :datetime)
      t.column(:created_at, :datetime)
    end

    drop_table(:auto_logins)
  end

  def self.down
    drop_table(:user_activities)
    drop_table(:tokens)

    remove_column(:users, :salt)
    add_column(:users, :last_login, :datetime)
    add_column(:users, :password_reset_token, :string)
    add_column(:users, :password_reset_expiration, :datetime)

    create_table "auto_logins", :force => true do |t|
      t.column "token", :string
      t.column "user_id", :integer
    end
  
  end
end