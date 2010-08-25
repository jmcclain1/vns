class CreateEvdModelyears < EvdMigration
  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_modelyears"""
      sql2 = """CREATE TABLE vns_modelyears
                SELECT VT50_ModelYear.modelyearid AS id,
	                     VT50_ModelYear.modelid     AS model_id,
	                     VT50_ModelYear.yearcode    AS year_code,
	                     VT51_Acodes.acode          AS acode
                FROM   VT50_ModelYear, VT51_Acodes
                WHERE  VT51_Acodes.modelyearid = VT50_ModelYear.modelyearid"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_modelyears")
    end
  end
end
