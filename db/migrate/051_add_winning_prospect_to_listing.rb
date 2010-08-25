class AddWinningProspectToListing < ActiveRecord::Migration
  def self.up
    add_column    :listings, :winning_prospect_id, :integer
  end

  def self.down
    remove_column :listings, :winning_prospect_id
  end
end
