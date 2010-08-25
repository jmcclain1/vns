class CreateEvdTrims < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_trims"""
      sql2 = """CREATE TABLE vns_trims
                SELECT acode,
                       doors,
                       wheelbase,
                       GVWR,
                       drivetype AS drive,
                       bodystyle AS body,
                       trimdesc  AS trim,
                       modelid   AS model_id,
                       yearcode
                FROM   VT05_Trim
                WHERE  lngcode = 'EN'"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_trims;")
    end
  end
end
