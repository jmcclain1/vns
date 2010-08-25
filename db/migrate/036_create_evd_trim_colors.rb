class CreateEvdTrimColors < EvdMigration
  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_colors"""
      sql2 = """CREATE TABLE vns_colors (UNIQUE (id))
                SELECT concat(acode, optionid) AS id,
                       optionid AS option_id,
                       description AS name,
                   	   rgb,
                       acode,
                       painttype AS paint_type
                FROM   VT17_TrimOptions
                WHERE  availability = 'C'"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_colors")
    end
  end
end
