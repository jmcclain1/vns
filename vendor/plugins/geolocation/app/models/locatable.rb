module Locatable
  def self.included(base)

    base.class_eval do
      belongs_to :location

      def self.find_within_radius(starting_point, distance, find_options = {})
        search_area = self.calculate_search_area(starting_point, distance)

        conditions = "locations.latitude <= ? AND locations.latitude >= ? AND locations.longitude >= ? AND locations.longitude <= ?"

        values = [search_area[:max_latitude],
        search_area[:min_latitude],
        search_area[:min_longitude],
        search_area[:max_longitude]]


        if find_options[:conditions]
          conditions = conditions + " AND " + find_options[:conditions].first
          values = values + find_options[:conditions].slice(1..(find_options[:conditions].length-1))
          find_options.delete(:conditions)
        end

        actual_options = find_options.merge({:conditions => [conditions] + values, :include => :location})
        self.find(:all, actual_options)
      end

      def self.calculate_search_area(starting_point, distance, options = {})
        raise ArgumentError.new("starting_point longitude and latitude must have a real value") if starting_point.nil? ||
          starting_point.latitude.nil? || starting_point.longitude.nil?
        radius = distance.to_f
        latR = radius / ((6076 / 5280) * 60)
        lonR = radius / (((Math.cos(starting_point.latitude * Math::PI / 180) * 6076) / 5280) * 60)

        {
          :min_latitude => starting_point.latitude - latR,
          :min_longitude => starting_point.longitude - lonR,
          :max_latitude => starting_point.latitude + latR,
          :max_longitude => starting_point.longitude + lonR
        }
      end

      ["address", "city", "region", "postal_code", "country", "longitude", "latitude"].each do |prop|
        define_method(prop) do
          location ? location.send(prop) : nil
        end

        define_method("#{prop}=") do |val|
          unless location.nil?
            location.send("#{prop}=", val)
            location.located_by = nil
          end
        end
      end
    end
  end


  def locator=(locator)
    @locator = locator
  end

  def locator
    @locator ||= Geolocator.default
  end

  def locate!(search_text = nil)
    if search_text
      location = locator.locate(search_text)
      location.save
      self.location = location
    else
      raise "Please attach a location to your locatable" if self.location.nil?
      self.location.update_attributes(locator.locate(self.location).attributes)
    end
  end
end