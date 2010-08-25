class ActiveRecord::Base

  def self.distance_sort_sql(origin,sort_order)
    origin_lat_sin = Math::sin(origin.location.latitude * Math::PI / 180.0) # precompute sin(lat)
    origin_lat_cos = Math::cos(origin.location.latitude * Math::PI / 180.0) # procompute cos(lat)
    inverted_sort_order = (sort_order == 'ASC' ? 'DESC' : 'ASC') # need to invert the sort direction for this formula
    "(#{origin_lat_sin}*SIN(RADIANS(locations.latitude)) + #{origin_lat_cos}*COS(RADIANS(locations.latitude))*COS(RADIANS(locations.longitude-(#{origin.location.longitude})))) #{inverted_sort_order}"
  end

  def self.distance_sql(origin)
    # use more accurate haversine formula to calculate actual distances
    cos_lat_origin = Math::cos(origin.location.latitude * Math::PI / 180.0) # procompute cos(origin.lat)
    """
      7919.742*ASIN(SQRT(POWER(SIN(RADIANS(locations.latitude-(#{origin.location.latitude}))/2),2)+
      (#{cos_lat_origin})*COS(RADIANS(locations.latitude))*
      POWER(SIN(RADIANS(locations.longitude-(#{origin.location.longitude}))/2),2)))
    """
  end

  def strip_commas(value)
    if value.is_a?(String)
      value.gsub(',', '')
    else
      value
    end
  end

  def strip_money(value)
    if value.is_a?(String)
      self.strip_commas(value).gsub('$', '')
    else
      value
    end
  end
  
  def self.evd_db
    ActiveRecord::Base.configurations['evd_ro']['database']
  end

  def self.yearcode_to_year(yearcode)
    decade_hash = { 'A' => 1990, 'B' => 2000, 'C' => 2010, 'D' => 2020 }
    decade_hash[yearcode[0,1]] + yearcode[1,1].to_i
  end

  def yearcode_to_year(yearcode)
    self.yearcode_to_year(yearcode)
  end
  
  def self.year_to_yearcode(year)
    decade_part = year.to_s[0..2]
    decade_to_letter_hash = { '199' => 'A', '200' => 'B', '201' => 'C', '202' => 'D' }
    year_part = year.to_s[3..3]
    yearcode = decade_to_letter_hash[decade_part] + year_part + '0'
  end
end

