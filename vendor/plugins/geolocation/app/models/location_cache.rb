class LocationCache < ActiveRecord::Base
  belongs_to :location

  def self.lookup(location_string)
    cache = find_by_location_string(location_string)
    return nil if cache.nil?
    cache.location
  end

  def self.cache(location_string, location)
    location.save if location.new_record?
    LocationCache.create(:location_string => location_string, :location => location)
  end

  def self.expire(location_string)
    cache = find_by_location_string(location_string)
    cache.destroy unless cache.nil?
  end
end