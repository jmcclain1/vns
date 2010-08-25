class CachingLocator < Geolocator
  def initialize(locator)
    @internal_locator = locator
  end

  def location_search(string)
    cached_location = LocationCache.lookup(string)
    if cached_location.nil?
      location = @internal_locator.location_search(string)
      LocationCache.cache(string, location)
      return location
    else
      return cached_location
    end
  end
end