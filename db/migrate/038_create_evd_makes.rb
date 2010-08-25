class CreateEvdMakes < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_makes"""
      sql2 = """CREATE TABLE vns_makes
                SELECT divcode AS div_code,
	                     divdesc AS name,
                       mfguid
                FROM   VT02_Division"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_makes")
    end
  end
end
