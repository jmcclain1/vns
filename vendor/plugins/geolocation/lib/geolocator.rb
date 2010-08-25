class Geolocator
  def self.default
    @@default ||= GoogleLocator.new(:google_key => GOOGLE_LOCATOR_KEY)
  end

  def self.default=(locator)
    @@default = locator
  end

  def locate(search_term = nil)
    case search_term
    when String
      location_search(search_term)
    when Location
      terms = [search_term.address, search_term.city, search_term.region, search_term.postal_code, search_term.country]
      terms -= ["", nil]
      location_search(terms.join(", "))
    end
  end

  def xpath_text(xml, xpath)
    element = xml.search(xpath)
    return nil if element.empty?
    text = element.text
    return nil if text.blank?
    return text
  end
end