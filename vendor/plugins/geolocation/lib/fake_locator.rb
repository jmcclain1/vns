class FakeLocator < Geolocator
  def initialize
    @cache = {}
    add_cache_element("123 Main, SF, CA, 94104, US", 37.791642, -122.394438, "123 Main", "SF", "CA", "94104", "US")
    add_cache_element("880 Lombard St, San Francisco, CA, 94133", 37.802587, -122.415913, "880 Lombard St", "San Francisco", "CA", "94133", "US")
    add_cache_element("870 Market St, San Francisco, 94102", 37.784842, -122.407269, "870 Market St", "San Francisco", "CA", "94102", "US")
    add_cache_element("94102", 37.7789, -122.4195, nil, nil, nil, "94102", "US")
    add_cache_element("75070, US", 33.1946, -96.6894, nil, nil, nil, "75070", "US")
    add_cache_element('123 Main, Pensacola, FL, 94102, US', 0.0, 0.0, "123 Main", "Pensacola", "FL", "94102", "US")
  end
  
  def add_cache_element(params, latitude, longitude, address, city, region, postal_code, country)
    @cache[params] = {:latitude => latitude, :longitude => longitude, :located_by => "FakeLocator", :address => address,
      :city => city, :region => region, :postal_code => postal_code, :country => country}
  end

  def location_search(string)
    Location.new(@cache[string])
  end

end