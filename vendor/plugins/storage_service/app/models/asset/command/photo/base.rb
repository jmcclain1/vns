require 'RMagick'

class Asset::Command::Photo::Base < Asset::Command::Base
  attr_accessor :width, :height
  
  def initialize(width, height)
    self.width = width
    self.height = height
  end

  def do(data)
    raise "cannot pass nil to Photo::Base" if data.nil?
    image = process(Magick::Image.from_blob(data.read).first)
    StringIO.new(image.to_blob)
  end

  def self.orientation(image)
    return :landscape if image.rows < image.columns
    return :portrait if image.rows > image.columns
    return :square
  end

  def extension
    nil
  end

  def size
    AssetVersion::Size.new(width, height)
  end

  protected
  def process(image)
    raise "override me"
  end
end
