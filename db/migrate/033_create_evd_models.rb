class CreateEvdModels < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_models"""
      sql2 = """CREATE TABLE vns_models
               SELECT VT04_Model.modelid   AS id,
	                    VT04_Model.modeldesc AS name,
                      VT04_Model.divcode AS make_id,
	                    VT02_Division.mfguid AS manufacturer_id
               FROM   VT04_Model, VT02_Division
               WHERE  VT04_Model.lngcode = 'EN' AND
	                    VT04_Model.divcode = VT02_Division.divcode"""

      execute sql1
      execute sql2
    end
  end

  def self.down
    migrate_evd do
      execute("DROP TABLE vns_models")
    end
  end
end
