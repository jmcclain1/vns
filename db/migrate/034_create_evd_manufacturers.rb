class CreateEvdManufacturers < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_manufacturers"""
      sql2 = """CREATE TABLE vns_manufacturers
               SELECT mfguid AS id,
	                    mfgdesc AS name
               FROM   VT57_MFGCodes"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_manufacturers")
    end
  end
end
