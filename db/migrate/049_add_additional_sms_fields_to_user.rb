class AddAdditionalSmsFieldsToUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :sms_receive_listing_expired
    remove_column :users, :sms_receive_new_offer
    add_column :users, :sms_wants_any_sms, :boolean, :default => true
    add_column :users, :sms_wants_new_offer, :boolean, :default => false
    add_column :users, :sms_wants_listing_expired, :boolean, :default => false
    add_column :users, :sms_wants_inquiry, :boolean, :default => false
    add_column :users, :sms_wants_reply, :boolean, :default => false
    add_column :users, :sms_wants_auction_won, :boolean, :default => false
    add_column :users, :sms_wants_auction_lost, :boolean, :default => false
    add_column :users, :sms_wants_auction_cancel, :boolean, :default => false
  end

  def self.down
    remove_column :users, :sms_wants_auction_cancel
    remove_column :users, :sms_wants_auction_lost
    remove_column :users, :sms_wants_auction_won
    remove_column :users, :sms_wants_reply
    remove_column :users, :sms_wants_inquiry
    remove_column :users, :sms_wants_listing_expired
    remove_column :users, :sms_wants_new_offer
    remove_column :users, :sms_wants_any_sms
    add_column    :users, :sms_receive_new_offer,       :boolean, :default => false
    add_column    :users, :sms_receive_listing_expired, :boolean, :default => false
  end
end
