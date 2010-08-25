class Location < ActiveRecord::Base
  set_table_name :locations

  EARTH_RADIUS = {:miles => 3963.1, :kilometers => 6288}

  def located?
    !located_by.nil?
  end

  def longitude_radians
    longitude * Math::PI/180
  end

  def latitude_radians
    latitude * Math::PI/180
  end

  def distance_from(other_location, options = {})
    raise NotYetLocatedError unless located?
    units = options[:units] || :miles
    Math.acos(
      Math.cos(latitude_radians) * Math.cos(longitude_radians) * Math.cos(other_location.latitude_radians) * Math.cos(other_location.longitude_radians) +
      Math.cos(latitude_radians) * Math.sin(longitude_radians) * Math.cos(other_location.latitude_radians) * Math.sin(other_location.longitude_radians) +
      Math.sin(latitude_radians) * Math.sin(other_location.latitude_radians)
    ) * EARTH_RADIUS[units]
  end

  class NotYetLocatedError < Exception
  end
end

