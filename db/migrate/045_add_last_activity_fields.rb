class AddLastActivityFields < ActiveRecord::Migration
  def self.up
    add_column    :prospects, :last_activity, :datetime
    add_column    :listings,  :last_activity, :datetime
  end

  def self.down
    remove_column :listings,  :last_activity
    remove_column :prospects, :last_activity
  end
end
