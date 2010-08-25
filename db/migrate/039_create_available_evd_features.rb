class CreateAvailableEvdFeatures < EvdMigration

  def self.up
    migrate_evd do
      sql1 = """DROP TABLE IF EXISTS vns_features"""
      sql2 = """CREATE TABLE vns_features
                             (id VARCHAR(24) UNIQUE,
                              acode VARCHAR(13),
                              availability CHAR(1),
                              name VARCHAR(255),
                              option_id INT(10),
                              cluster_id INT(10),
                              ecc VARCHAR(4),
                              engine TINYINT,
                              transmission TINYINT,
                              standard TINYINT,
                              optional TINYINT,
                              ecc_category VARCHAR(100))
                SELECT concat(options.acode, options.optionid) AS id,
                       options.acode                           AS acode,
                       options.availability                    AS availability,
                       options.description                     AS name,
                       options.optionid                        AS option_id,
                       options.clusterid                       AS cluster_id,
                       options.ecc                             AS ecc,
            		       options.ecc = '0027'                    AS engine,
            		       options.ecc = '0029'                    AS transmission,
            		       options.availability = 'S'              AS standard,
            		       options.availability = 'O'              AS optional,
                       codes.ECCDesc                           AS ecc_category
                FROM   VT17_TrimOptions AS options, CT01_ECCodes AS codes
                WHERE  options.ecc = codes.ecc
                       AND availability != 'C'
                       AND availability != 'V'
                       AND options.ecc IN ('0003','0007','0008','0009','0012','0013','0022','0023','0027','0029','0030','0031','0034','0037','0038','0043','0045','0046','0052','0053','0056','0057','0058','0060','0066','0067','0070','0087','0092','0093','0095')
                GROUP BY acode, description"""

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
