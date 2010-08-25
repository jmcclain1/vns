require 'fastercsv'
require 'active_record'

class EvdIiUpdater

  def initialize
    ActiveRecord::Base.establish_connection :evd_ii
    @db = ActiveRecord::Base.connection();
  end
  
  def load
    puts "EvdIiUpdater loading .... "
    load_manufacturers("evd_ii_vns")
    load_squish_vins("evd_ii_vns")
    load_trims("evd_ii_vns")
    load_models("evd_ii_vns")
    load_modelyears("evd_ii_vns")
    load_trim_colors("evd_ii_vns")
    load_makes("evd_ii_vns")
    load_squishvin_acode_join_table("evd_ii_vns")
    load_available_features("evd_ii_vns")
    puts "Done"
  end
  
#  def load_small
#    puts "EvdIiUpdater loading small dev db ...."
#    load_manufacturers("evd_development")
#    load_squish_vins("evd_development")
#    load_trims("evd_development")
#    load_models("evd_development")
#    load_modelyears("evd_development")
#    load_trim_colors("evd_development")
#    load_makes("evd_development")
#    load_squishvin_acode_join_table("evd_development")
#    load_available_features("evd_development")
#    puts "Done"
#  end
  
  def load_manufacturers(which_source) ###
    # set up the manufacturers table
    puts "... manufacturers"
    sql1 = """DROP TABLE IF EXISTS vns_manufacturers"""
    sql2 = """CREATE TABLE vns_manufacturers 
             (INDEX (id))
             SELECT mfguid AS id,
                    mfgdesc AS name
             FROM   #{which_source}.VT57_MFGCodes"""

    @db.execute(sql1)
    @db.execute(sql2)
  end

  def load_squish_vins(which_source) ###
    puts "... squish vins"
    sql1 = """DROP TABLE IF EXISTS vns_squish_vins"""
    sql2 = """CREATE TABLE vns_squish_vins (INDEX (squish_vin), INDEX (acode))
              SELECT SV AS squish_vin,
                     acode
              FROM   #{which_source}.VN01_SquishVIN"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_trims(which_source) ###
    puts "... trims"
    sql1 = """DROP TABLE IF EXISTS vns_trims"""
    sql2 = """CREATE TABLE vns_trims (INDEX (acode), INDEX (model_id))
              SELECT acode,
                     doors,
                     wheelbase,
                     GVWR,
                     drivetype AS drive,
                     bodystyle AS body,
                     trimdesc  AS trim,
                     modelid   AS model_id,
                     yearcode
              FROM   #{which_source}.VT05_Trim
              WHERE  lngcode = 'EN'"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_models(which_source)  ###
    puts "... models"
    sql1 = """DROP TABLE IF EXISTS vns_models"""
    sql2 = """CREATE TABLE vns_models (INDEX (id), INDEX (make_id), INDEX (manufacturer_id))
             SELECT VT04_Model.modelid   AS id,
                    VT04_Model.modeldesc AS name,
                    VT04_Model.divcode AS make_id,
                    VT02_Division.mfguid AS manufacturer_id
             FROM   #{which_source}.VT04_Model, #{which_source}.VT02_Division
             WHERE  VT04_Model.lngcode = 'EN' AND
                    VT04_Model.countrycode = 'US' AND
                    VT02_Division.lngcode = 'EN' AND
                    VT02_Division.countrycode = 'US' AND
                    VT04_Model.divcode = VT02_Division.divcode"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_modelyears(which_source) ###
    puts "... model years"
    sql1 = """DROP TABLE IF EXISTS vns_modelyears"""
    sql2 = """CREATE TABLE vns_modelyears (INDEX (id), INDEX (model_id), INDEX (acode))
              SELECT VT50_ModelYear.modelyearid AS id,
                     VT50_ModelYear.modelid     AS model_id,
                     VT50_ModelYear.yearcode    AS year_code,
                     VT51_Acodes.acode          AS acode
              FROM   #{which_source}.VT50_ModelYear, #{which_source}.VT51_Acodes
              WHERE  VT51_Acodes.modelyearid = VT50_ModelYear.modelyearid AND
                     VT50_ModelYear.lngcode = 'EN'"""
  
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_trim_colors(which_source) ###
    puts "... trim colors"
    sql1 = """DROP TABLE IF EXISTS vns_colors"""
    sql2 = """CREATE TABLE vns_colors (INDEX (id), INDEX (acode))
              SELECT concat(acode, optlevel, optcode) AS id,
                     optcode AS option_id,
                     description AS name,
                     rgb,
                     acode,
                     painttype AS paint_type
              FROM   #{which_source}.VT17_TrimOptions
              WHERE  availability = 'C'"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_makes(which_source) ###
    puts "... makes"
    sql1 = """DROP TABLE IF EXISTS vns_makes"""
    sql2 = """CREATE TABLE vns_makes (INDEX (div_code))
              SELECT divcode AS div_code,
                     divdesc AS name,
                     mfguid
              FROM   #{which_source}.VT02_Division
              WHERE  lngcode = 'EN'
                     AND  countrycode = 'US'"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_squishvin_acode_join_table(which_source) ###
    puts "... squish-acode join table"
    sql1 = """DROP TABLE IF EXISTS vns_squish_vins_acodes"""
    sql2 = """CREATE TABLE vns_squish_vins_acodes (INDEX (squish_vin), INDEX (acode))
              SELECT VN01_SquishVIN.sv AS squish_vin,
                     VN01_SquishVIN.acode
              FROM   #{which_source}.VN01_SquishVIN, #{which_source}.VT05_Trim
              WHERE  VN01_SquishVIN.acode = VT05_Trim.acode
              GROUP BY squish_vin, VT05_Trim.TrimDesc, VT05_Trim.yearcode"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end
  
  def load_available_features(which_source) ###
    puts "... available features"
    sql1 = """DROP TABLE IF EXISTS vns_features"""
    sql2 = """CREATE TABLE vns_features
              (INDEX (id), INDEX (acode))
              SELECT concat(options.acode, options.optlevel, options.optcode) AS id,
                     options.acode                           AS acode,
                     options.availability                    AS availability,
                     options.description                     AS name,
                     options.optcode                         AS option_id,
                     options.clusterid                       AS cluster_id,
                     options.ecc                             AS ecc,
                     options.ecc = '0027'                    AS engine,
                     options.ecc = '0029'                    AS transmission,
                     options.availability = 'S'              AS standard,
                     options.availability = 'O'              AS optional,
                     codes.ECCDesc                           AS ecc_category
              FROM   #{which_source}.VT17_TrimOptions AS options, #{which_source}.CT01_ECCodes AS codes
              WHERE  options.ecc = codes.ecc
                     AND availability != 'C'
                     AND availability != 'V'
                     AND options.ecc IN ('0003','0007','0008','0009','0012','0013','0022','0023','0027','0029','0030','0031','0034','0037','0038','0043','0045','0046','0052','0053','0056','0057','0058','0060','0066','0067','0070','0087','0092','0093','0095')
              GROUP BY acode, description"""
    
    @db.execute(sql1)
    @db.execute(sql2)
  end

end