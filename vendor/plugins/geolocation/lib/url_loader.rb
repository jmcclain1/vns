require 'open-uri'
require 'uri'
require 'rexml/document'
require 'hpricot'

class UrlLoader
  def initialize(url)
    @url = url
  end

  attr_reader :url

  def add_parameter(param_name, param_value)
    delimiter = @url.include?("?") ? "&" : "?"
    @url << delimiter << param_name << "=" << URI.escape(param_value.strip)
  end

  def load
    contents = []
    open(@url) do |f|
      f.each do |line|
        contents << line
      end
    end
    contents.join("\n")
  end

  def load_xml
    contents = load
    begin
      xml = Hpricot(contents)
      raise MalformedXmlException if xml.nil? || !xml.children.any? {|child| child.xmldecl?}
      xml
    rescue => e
      RAILS_DEFAULT_LOGGER.error(e)
      raise MalformedXmlException.new(e)
    end
  end

end