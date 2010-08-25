class RecreateAvailableFeaturesTable < EvdMigration
  def self.up
    CreateAvailableEvdFeatures.up
  end

  def self.down
    # do nothing at all!
  end
end
