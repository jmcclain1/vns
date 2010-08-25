require 'fastercsv'

# hack to get access to private "config" property of db connection adapter
class ActiveRecord::ConnectionAdapters::MysqlAdapter
  public
  def config
    @config
  end
end

class EdImporter

  FILES = {
    :models => 'USED_VEHICLE_NAMES_sample.tab.txt',
    :colors => 'USED_COLORS_sample.tab.txt',
    :engines_transmissions => 'USED_ENGINES_TRANSMISSIONS_sample.tab.txt',
    :features => 'USED_FEATURE_LOOKUP_sample.tab.txt',
    :feature_std => 'USED_STANDARD_FEATURES_sample.tab.txt',
    :feature_opt => 'USED_OPTIONAL_FEATURES_sample.tab.txt',
    :styles => 'USED_SPECIFICATIONS_sample.tab.txt',
    :vins => 'ED_SQUISH_VIN_ALL_3_sample.tab.txt'
  }

  def initialize
    @db_file = "#{RAILS_ROOT}/db/imported_auto_data.sql"

    c = ActiveRecord::Base.connection.config
    @username = c[:username]
    @password = c[:password]
    @database = c[:database]
  end

  def import
    clear
    b = Benchmark.measure do
      import_table :styles
      import_table :models
      import_table :colors
      import_table :engines_and_transmissions
      import_table :vins
    end
    puts "Total took #{b.total} sec"

    system("mysqldump -u #{@username} -p#{@password} #{@database} > #{@db_file}")
  end

  def clear
    Make.delete_all
    Model.delete_all
    Style.delete_all

    Color.delete_all
    Engine.delete_all
    Transmission.delete_all
    Clutch.delete_all
    Motorization.delete_all
    Vin.delete_all
    Identification.delete_all
  end

  def load
    system("mysql -u #{@username} -p#{@password} #{@database} < #{@db_file}")
  end

  protected

  def import_table(which)
    print "Importing #{which}"
    STDOUT.flush
    c = 0
    b = Benchmark.measure { c = self.send("import_#{which}") }
    puts "Imported #{c} #{which} in #{b.total} sec"
  end

  def import_file(which_file)
    c = 0
    FasterCSV.foreach("#{RAILS_ROOT}/vendor/edmunds/#{FILES[which_file]}", :col_sep => "\t", :headers => true, :skip_blanks => true) do |row|
      yield row
      c = c+1
      if (c % 100 == 0)
        print "."
        STDOUT.flush
      end
    end
    puts
    c
  end

  def import_styles
    import_file(:styles) do |row|
      row_id = row['ED_STYLE_ID'].strip
      style = Style.find_by_ad_style_id(row_id) || Style.new(:ad_style_id => row_id)

      style.drive = row['DRIVE_TYPE_CODE'].strip
      style.doors = row['DOORS']
      style.body = row['BODY_STYLE'].strip

      style.save(false)
    end
  end

  def import_models
    import_file(:models) do |row|
      row_id = row['ED_MODEL_ID'].strip
      row_make = row['MAKE'].strip
      model = Model.find_by_ad_model_id(row_id) || Model.new(:ad_model_id => row_id)
      make = Make.find_by_name(row_make) || Make.create(:name => row_make)
      style = Style.find_by_ad_style_id(row['ED_STYLE_ID'].strip)

      unless style
        puts "Style #{row['ED_STYLE_ID']} not found for model #{row_id}"
      else
        model.ad_model_id = row_id
        model.year = row['YEAR']
        model.name = row['MODEL'].strip
        model.make = make
        update_style_with_model(:style => style, :model => model, :trim => row['TRIM'], :description => row['STYLE'])

        model.save!        
      end
    end
  end

  def import_colors
    import_file(:colors) do |row|
      name = row['MANUFACTURER_COLOR_NAME'].strip
      code = row['MANUFACTURER_COLOR_CODE'].strip
      style = Style.find_by_ad_style_id(row['ED_STYLE_ID'].strip)
      unless style
        puts "Style #{style} not found for color #{name} [code: #{code}]"
      else
        color = Color.create(
          :style => style,
          :name => name,
          :code => code,
          :exterior => (row['INT_OR_EXT'].strip == 'E'),
          :r_code => row['R_CODE'],
          :g_code => row['G_CODE'],
          :b_code => row['B_CODE'],
          :generic_name => row['GENERIC_COLOR'].strip)
      end
    end
  end

  def import_engines_and_transmissions
    import_file(:engines_transmissions) do |row|
      name = row['DESCRIPTION'].strip
      is_engine = (row['ENGINE_TRANSMISSION'].strip == 'E')
      is_standard = (row['STANDARD_OPTIONAL'].strip == 'S')
      ed_style_id = row['ED_STYLE_ID'].strip
      style = Style.find_by_ad_style_id(ed_style_id)
      unless style
        puts "Style #{ed_style_id} not found for engine/transmission #{name}"
      else
        if is_engine
          engine = Engine.find_by_name(name) || Engine.new(:name => name)
          code = row['ENGINE_CODE']
          begin
            engine.code = code
          rescue SyntaxError
            # TODO: if engine_code isn't correct, what to do?  Still need to add to database to make Style valid
          ensure
            engine.save!
            style.motorizations.create(:engine => engine, :standard => is_standard)
          end
        else
          transmission = Transmission.find_by_name(name) || Transmission.new(:name => name)
          transmission.kind = transmission_kind(name)
          _, speed = /(\d+)-[Ss]peed/.match(name).to_a
          transmission.speed = speed
          transmission.save!
          style.clutches.create(:transmission => transmission, :standard => is_standard)
        end
      end
    end
  end

  def transmission_kind(name)
    if /Automatic/.match(name)
      Transmission::AUTOMATIC
     elsif /Manual/.match(name)
      Transmission::MANUAL
     else
      nil
    end
  end

  def import_vins
    import_file(:vins) do |row|
      style_id = extract_style_id(row)
      squish_vin = row['SQUISH_VIN'].strip
      style = Style.find_by_ad_style_id(style_id)
      unless style
        puts "Style #{style_id} not found for squish VIN #{squish_vin}"
        next
      end

      vin = Vin.find_by_squish_vin(squish_vin)
      unless vin
        vin = Vin.new(:squish_vin => squish_vin)
        vin.save!
      end
      style.identifications.create(:vin_id => vin.id)
    end
  end

  def extract_style_id(row)
    alt_style_id = row['USED_ED_STYLE_ID'].to_s.strip
    style_id = (alt_style_id.blank? ? row['ED_STYLE_ID'].strip : alt_style_id)
    style_id
  end

  private
  def update_style_with_model(options)
    style = options[:style]
    model = options[:model]

    style.model = model

    raise "Existing trim #{style.trim} does not match #{options[:trim]}" if !style.trim.blank? && style.trim != options[:trim]
    style.trim = options[:trim]

    raise "Existing description #{style.description} does not match #{options[:description]}" if !style.description.blank? && style.description != options[:description]
    style.description = options[:description]
    style.save!
  end
end