class ChangeDraftToStateInListings < ActiveRecord::Migration
  def self.up
    remove_column :listings, :draft
    add_column    :listings, :state, :string,  :default => 'draft'
  end

  def self.down
    remove_column :listings, :state
    add_column    :listings, :draft, :boolean, :default => true
  end
end
