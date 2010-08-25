module VehicleField

  ALL = FieldMap.new(
    Field::DateTime.new(:created_at, "Created at"),
    Field::DateTime.new(:updated_at, "Updated at"),

    Field::Text.new(:vin, "VIN"),
    Field::Text.new(:year, "Year"),
    Field::Text.new(:make_name, "Make"),
    Field::Text.new(:model_name, "Model"),
    Field::Text.new(:trim_name, "Trim"),
    Field::Text.new(:engine_name, "Engine"),
    Field::Text.new(:drive_name, "Drivetrain"),
    Field::Text.new(:transmission_name, "Transmission"),

    Field::YesNo.new(:title, "Title",
      :onclick => "if($('vehicle_title_false').checked) {$('vehicle_title_state').disabled = true} else {$('vehicle_title_state').disabled = false}"),

    Field::State.new(:title_state, "Title state"),
    Field::YesNo.new(:certified, "Certified"),
    Field::Text.new(:stock_number, "Stock number"),
    Field::Text.new(:odometer, "Odometer"),
    Field::Color.new(:exterior_color, "Exterior Color"),
    Field::Color.new(:interior_color, "Interior Color"),
    Field::YesNo.new(:frame_damage, "Frame damage"),
    Field::YesNo.new(:prior_paint, "Prior paint"),
    Field::Text.new(:location, "Location"),
    Field::Money.new(:actual_cash_value, "Actual cash value", {:size => 10}),
    Field::Money.new(:cost, "Cost", {:size => 10}),
    Field::TextArea.new(:comments, "Comments")
  )

  STATIC = ALL.some(
    :vin,
    :year,
    :make_name,
    :model_name,
    :trim_name,
    :engine_name,
    :drive_name,
    :transmission_name
  )

  DATES = ALL.some(
    :created_at,
    :updated_at
  )

  EDITABLE = ALL.some(
    :title,
    :title_state,
    :certified,
    :stock_number,
    :odometer,
    :exterior_color,
    :interior_color,
    :frame_damage,
    :prior_paint,
    :location,
    :actual_cash_value,
    :cost,
    :comments
  )

end
