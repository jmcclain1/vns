require 'open-uri'
class AssociationShim < ActiveRecord::Base
end

class Asset < ActiveRecord::Base
  validates_presence_of :data, :on => :create, :if => lambda {|asset| !asset.external?}
  validates_each :format  do |record, key, value|
    if record.data_is_dirty && !(record.class == Asset) && !(record.is_a? class_by_extension(get_extension(record.original_filename)))
      record.errors.add(:format, "Please upload a #{self}")
    end
  end

  set_table_name :assets
  acts_as_list :scope => :creator_id

  has_many :assets_associations, :dependent => :destroy, :class_name => 'AssetsAssociation'

  belongs_to :creator, :foreign_key => :creator_id, :class_name => "User"
  has_many :versions, :class_name => 'AssetVersion', :include => [:asset], :dependent => :destroy do
    def [](version_name)
      if existing_version = self.detect{ |v| v.version == version_name.to_s }
        existing_version
      else
        command = proxy_owner.class.versions[version_name]
        raise "Can't find command for version :#{version_name} in #{proxy_owner.class}" unless command
        ASSET_WORKER.do(command, proxy_owner, version_name)
        self.find_by_version(version_name.to_s)
      end
    end
  end

  after_destroy :remove_asset
  after_save :store_asset
  
  attr_accessor :data_is_dirty

  FILE_TYPES = YAML.load(File.new(File.join(File.dirname(__FILE__), *%w[.. .. config extensions.yml]))) unless const_defined?(:FILE_TYPES)

  def self.has_versions(versions)
    raise "you can't use a key called original because otherwise bad things will happen" if versions.key?(:original) 

    @versions = versions
  end
  
  def format
    self.class
  end

  def self.versions
    @versions || {}
  end

  def self.has_version?(version)
    versions.keys.include?(version)
  end
  
  def initialize(*args, &block)
    super
    self.original_filename ||= self.class.asset_filename(args.first || {})
  end

  #TODO: WARNING and I mean SORRY. This will not scale, but better than has_many_polymorphs insanity.
  def associates
    assets_associations.map(&:associate)
  end

  def has_version?(version)
    !self[version].nil?
  end

  def url(version = :original)
    self.versions[version].url
  end

  def data
    @data || self.versions[:original].data
  rescue
    nil
  end

  def data=(value)
    @data_is_dirty = true
    if value.kind_of?(String)
      @data = open(value)
      self.source_uri = value
    else
      @data = value.to_tempfile
    end
  end

  def external?
    !self.source_uri.nil?
  end

  def self.new_by_file(params={})
    new_from_upload(params, nil, class_by_filename(asset_filename(params)))
  end

  def self.asset_filename(params)
    params[:original_filename] || (params[:data] && params[:data].original_filename)
  end

  def self.new_from_upload(params, upload=nil, asset_class=self)
    params[:data] = upload if upload
    asset = asset_class.new(params)
    asset.original_filename = asset_filename(params)
    return asset
  end

  def read
    data.rewind
    data.read
  end

  protected
  def self.class_by_extension(extension)
    return (FILE_TYPES[extension]).constantize rescue UnknownAsset
  end
  
  def self.class_by_filename(filename)
    class_by_extension(get_extension(filename))
  end

  def self.get_extension(filename)
    filename.match(/\.([^.]+)$/)[1].downcase rescue :undefined
  end

  def remove_asset
    self.versions.each do |version|
      version.destroy
    end
  end

  def store_asset
    return true unless @data_is_dirty
    @data_is_dirty = false
    ASSET_WORKER.do(Asset::Command::Identity.new, self, :original)
    self.class.versions.each do |version_name, command|
      ASSET_WORKER.do(command, self, version_name)
    end
  end
end