class AddSmsFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :sms_address, :string
    add_column :users, :sms_receive_new_offer, :boolean, :default => false
    add_column :users, :sms_receive_listing_expired, :boolean, :default => false
  end

  def self.down
    remove_column :users, :sms_address
    remove_column :users, :sms_receive_new_offer
    remove_column :users, :sms_receive_listing_expired
  end
end
