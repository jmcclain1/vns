class GoogleLocator < Geolocator
  def initialize(options = {})
    @google_key = options[:google_key] || ""
  end

  def location_search(search_term)
    loader = UrlLoader.new("http://maps.google.com/maps/geo")
    loader.add_parameter("q", search_term)
    loader.add_parameter("output", "xml")
    loader.add_parameter("key", @google_key)

    xml = loader.load_xml
    raise ServiceDown if xml.at("/kml").nil?
    status = xml.search("//status/code").text
    raise InvalidGoogleKey if status == "610"
    raise NotASuccess.new(status) unless status == "200"

    coords = xml.search("//placemark/point/coordinates").text.split(",")
    accuracy_code = xml.at("//addressdetails").attributes["accuracy"].to_i
    accuracy = ["googlecode0", "googlecode1", "region", "googlecode3", "city", "district", "street", "googlecode7", "exact"][accuracy_code]
    location = Location.new(
      :address => xpath_text(xml, "//thoroughfare/thoroughfarename"),
      :city => xpath_text(xml, "//locality/localityname"),
      :region => xpath_text(xml, "//administrativearea/administrativeareaname"),
      :country => xpath_text(xml, "//country/countrynamecode"),
      :postal_code => xpath_text(xml, "//postalcode/postalcodenumber"),
      :latitude => coords[1].to_f,
      :longitude => coords[0].to_f,
      :located_by => "GoogleLocator",
      :located_at => Time.now,
      :accuracy => accuracy
    )
    return location
  rescue MalformedXmlException
    raise ServiceDown
  end

  class InvalidGoogleKey < Exception
  end

  class ServiceDown < Exception
  end

  class NotASuccess < Exception
  end
end