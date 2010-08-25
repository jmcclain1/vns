class EvdVehicleFixtureGenerator
  def self.find_for_acode(acode)
    trim = Evd::Trim.find(acode)

    vin = valid_vin_from_trim(trim)

    interior_color = trim.interior_colors.first
    exterior_color = trim.exterior_colors.first

    output_stuff(trim, vin, interior_color, exterior_color)
  end

  def self.valid_vin_from_trim(trim)
    squish_vin = trim.squish_vins.first.squish_vin
    full_vin = squish_vin[0,8] + "0" + squish_vin[8,2] + "123456"
  end

  def self.output_stuff(trim, vin, interior_color, exterior_color)
    puts "trim_id: #{trim.acode}"
    puts "vin: #{vin}"
    puts "interior_color_id: #{interior_color.rgb}"
    puts "exterior_color_id: #{exterior_color.rgb}"
  end
end