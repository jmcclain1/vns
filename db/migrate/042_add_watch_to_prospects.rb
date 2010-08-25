class AddWatchToProspects < ActiveRecord::Migration
  def self.up
    add_column    :prospects, :watch,  :boolean, :default => false
    add_column    :prospects, :source, :string,  :default => ''
    remove_column :prospects, :type
  end

  def self.down
    add_column    :prospects, :type,   :string,  :default => 'WatchProspect'
    remove_column :prospects, :source
    remove_column :prospects, :watch
  end
end
