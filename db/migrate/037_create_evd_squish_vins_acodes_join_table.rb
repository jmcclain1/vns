class CreateEvdSquishVinsAcodesJoinTable < EvdMigration
  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_squish_vins_acodes"""
      sql2 = """CREATE TABLE vns_squish_vins_acodes (INDEX (squish_vin))
                SELECT VN01_SquishVIN.sv AS squish_vin,
                       VN01_SquishVIN.acode
                FROM   VN01_SquishVIN, VT05_Trim
                WHERE  VN01_SquishVIN.acode = VT05_Trim.acode
                GROUP BY squish_vin, VT05_Trim.TrimDesc, VT05_Trim.yearcode"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_squish_vins_acodes")
    end
  end
end
