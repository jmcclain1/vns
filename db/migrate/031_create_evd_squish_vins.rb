class CreateEvdSquishVins < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_squish_vins"""
      sql2 = """CREATE TABLE vns_squish_vins
                SELECT SV AS squish_vin,
                       acode
                FROM   VN01_SquishVIN"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_squish_vins;")
    end
  end
end
