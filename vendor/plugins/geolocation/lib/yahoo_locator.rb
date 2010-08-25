class YahooLocator < Geolocator
  def initialize(options = {})
    @key = options[:key] || "yahoodemo"
  end

  def location_search(string)
    loader = UrlLoader.new("http://local.yahooapis.com/MapsService/V1/geocode")
    loader.add_parameter("appid", @key)
    loader.add_parameter("location", string)

    xml = loader.load_xml
    error = xml.at("//error")
    if error
      message = xpath_text(xml, "//error/message")
      raise YahooLimitReached if message == "limit exceeded"
      raise YahooError.new(message)
    end

    accuracy_code = xml.at("//result").attributes["precision"]
    accuracy = {"address" => "exact", "zip" => "district"}[accuracy_code] || "YAHOO:#{accuracy_code}"
    location = Location.new(
      :address => xpath_text(xml, "//address"),
      :city => xpath_text(xml, "//city"),
      :region => xpath_text(xml, "//state"),
      :country => xpath_text(xml, "//country"),
      :postal_code => xpath_text(xml, "//zip"),
      :latitude => xpath_text(xml, "//latitude"),
      :longitude => xpath_text(xml, "//longitude"),
      :located_by => "YahooLocator",
      :located_at => Time.now,
      :accuracy => accuracy
    )
    return location
  rescue OpenURI::HTTPError => e
    puts e
    raise ServiceDownError
  end

  class ServiceDownError < Exception
  end

  class YahooError < Exception
  end

  class YahooLimitReached < Exception
  end
end