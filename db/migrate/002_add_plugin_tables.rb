class AddPluginTables < ActiveRecord::Migration
  extend PluginUtils
  
  def self.up
    migrate_plugin('storage_service', 15)
    migrate_plugin('user', 11)
    migrate_plugin('geolocation', 3)
  end

  def self.down
    migrate_plugin('user', 0)
    migrate_plugin('storage_service', 0)
  end
end
