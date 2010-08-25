class DefaultPhoto
  attr_accessor :impersonated_photo_class, :extension, :versions

  DefaultVersion = Struct.new(:url)
  
  def initialize(impersonated_photo_class, extension = 'png')
    self.impersonated_photo_class = impersonated_photo_class
    self.extension = extension
    self.versions = {}
    impersonated_photo_class.versions.merge({:original => nil}).each do |version_name, blah|
      versions[version_name] = DefaultVersion.new("/images/default_#{impersonated_photo_class.to_s.underscore}/#{version_name}.#{extension}")
    end
  end

  def id()
    nil
  end

  def url(version = :original)
    versions[version].url
  end
  
  def valid?
    true
  end
end
