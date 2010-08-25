# == Schema Information
# Schema version: 52
#
# Table name: vehicles
#
#  id                :integer(11)     not null, primary key
#  created_at        :datetime        
#  updated_at        :datetime        
#  vin               :string(17)      
#  trim_id           :string(255)     
#  exterior_color_id :string(255)     
#  interior_color_id :string(255)     
#  certified         :boolean(1)      
#  odometer          :decimal(10, 1)  
#  frame_damage      :boolean(1)      
#  prior_paint       :boolean(1)      
#  dealership_id     :integer(11)     
#  title             :boolean(1)      
#  title_state       :string(2)       
#  stock_number      :string(100)     
#  location          :string(100)     
#  actual_cash_value :decimal(10, 2)  
#  cost              :decimal(10, 2)  
#  comments          :text            
#  draft             :boolean(1)      default(TRUE)
#

# == Schema Information
# Schema version: 52
#
# Table name: vehicles
#
#  id                :integer(11)     not null, primary key
#  created_at        :datetime        
#  updated_at        :datetime        
#  vin               :string(17)      
#  trim_id           :string(255)     
#  exterior_color_id :string(255)     
#  interior_color_id :string(255)     
#  certified         :boolean(1)      
#  odometer          :decimal(10, 1)  
#  frame_damage      :boolean(1)      
#  prior_paint       :boolean(1)      
#  dealership_id     :integer(11)     
#  title             :boolean(1)      
#  title_state       :string(2)       
#  stock_number      :string(100)     
#  location          :string(100)     
#  actual_cash_value :decimal(10, 2)  
#  cost              :decimal(10, 2)  
#  comments          :text            
#  draft             :boolean(1)      default(TRUE)
#

# == Schema Information
# Schema version: 52
#
# Table name: vehicles
#
#  id                :integer(11)     not null, primary key
#  created_at        :datetime        
#  updated_at        :datetime        
#  vin               :string(17)      
#  trim_id           :string(255)     
#  exterior_color_id :string(255)     
#  interior_color_id :string(255)     
#  certified         :boolean(1)      
#  odometer          :decimal(10, 1)  
#  frame_damage      :boolean(1)      
#  prior_paint       :boolean(1)      
#  dealership_id     :integer(11)     
#  title             :boolean(1)      
#  title_state       :string(2)       
#  stock_number      :string(100)     
#  location          :string(100)     
#  actual_cash_value :decimal(10, 2)  
#  cost              :decimal(10, 2)  
#  comments          :text            
#  draft             :boolean(1)      default(TRUE)
#

class Vehicle < ActiveRecord::Base
  # should the default format be .png or .jpg?
  include Photoable.new(VehiclePhoto)

  belongs_to :dealership
  belongs_to :trim,
             :class_name => 'Evd::Trim',
             :foreign_key => 'trim_id'
  belongs_to :exterior_color,
             :class_name => "Evd::TrimColor",
             :foreign_key => 'exterior_color_id'
  belongs_to :interior_color,
             :class_name => "Evd::TrimColor",
             :foreign_key => 'interior_color_id'
  has_many :features
  has_many :listings,
            :order => 'listings.created_at DESC'
  has_many :images

  validates_length_of :vin, :is => 17
  validates_format_of :vin, :with => /^[A-Za-z0-9]*$/, :message =>"VIN must contain only letters and numbers"
  validates_presence_of :trim_id
  validates_numericality_of :odometer
  validates_inclusion_of :certified,    :in => [true, false]
  validates_inclusion_of :frame_damage, :in => [true, false]
  validates_inclusion_of :prior_paint,  :in => [true, false]
  validates_inclusion_of :title, :in => [true, false], :if => :dealership
  validates_inclusion_of :title_state,
                         :in => States::US.short_names,
                         :if => lambda {|v| v.title && v.dealership}
  validates_presence_of :stock_number, :if => :dealership
  Infinity = 1.0/0 # zomg
  validates_exclusion_of :actual_cash_value, :in => (-Infinity...0), :message => "Cost cannot be negative"
  validates_exclusion_of :cost, :in => (-Infinity...0), :message => "Cost cannot be negative"

  def listing
    self.listings[0]
  end

  def actual_cash_value=(value)
    self[:actual_cash_value] = strip_money(value)
  end

  def cost=(value)
    self[:cost] = strip_money(value)
  end

  def days_in_inventory
    days_in_inventory = Date.today.jd - self.added_at.to_date.jd
    return days_in_inventory + 1
  end

  def added_at
    self.created_at
  end

  def carfax_link
    "http://www.carfax.com/cfm/ccc_displayhistoryrpt.cfm?partner=VNS_0&vin=#{self.vin}"
  end

  def listable?
    (self.listing.nil? || self.listing.draft?) && self.title
  end
  
  def listed?
    self.listing && !self.listing.draft?
  end

  def display_name
    self.trim.characterization
  end

  def year
    self.trim.year
  end

  def manufacturer_name
    trim.model.manufacturer.name
  end

  def make_name
    trim.model.make.name
  end

  def model_name
    trim.model.name
  end

  def trim_name
    trim.trim
  end

  def engine_name
    feature = self.features.find_by_engine(true)
    if feature
      feature.name.gsub(/^Engine: /, '')
    else
      "Unknown"
    end
  end

  def drive_name
    self.trim.drive
  end

  def doors
    self.trim.doors
  end

  def transmission_name
    feature = self.features.find_by_transmission(true)
    if feature
      feature.name.gsub(/^Transmission: /, '')
    else
      "Unknown"
    end
  end

  def exterior_colors
    trim.exterior_colors
  end

  def interior_colors
    trim.interior_colors
  end

  def trims
    @trims ||= Evd::Trim.find_all_by_vin(self.vin)
  end

  def trim_with_default
    trim_without_default || trims.first
  end
  alias_method_chain :trim, :default

  def exterior_color_with_default
    exterior_color_without_default || exterior_colors.first
  end
  alias_method_chain :exterior_color, :default

  def interior_color_with_default
    interior_color_without_default || interior_colors.first
  end
  alias_method_chain :interior_color, :default

  def odometer=(value)
    self[:odometer] = strip_commas(value)
  end

  def title_states
    States::US.all
  end

  def self.paginate(params)
    user = params[:user]
    offset = params[:offset] || '0'
    limit  = params[:page_size] || '50'
    order_by = case
      when params[:s0] : "trims.yearcode #{params[:s0]}, makes.name, models.name"
      when params[:s1] : "makes.name #{params[:s1]}, models.name #{params[:s1]}, trims.yearcode"
      when params[:s2] : "(NOW() - created_at) #{params[:s2]}, trims.yearcode, makes.name, models.name"
      when params[:s3] : "title #{params[:s3]}, trims.yearcode, makes.name, models.name"
      else               "trims.yearcode, makes.name, models.name"
    end
    order_by += ", vehicles.id"
    vehicle_sql = <<-SQL
      SELECT vehicles.*
      FROM   vehicles, #{evd_db}.vns_trims AS trims, #{evd_db}.vns_models AS models, #{evd_db}.vns_makes AS makes
      WHERE  vehicles.trim_id = trims.acode and
             trims.model_id = models.id and
             models.make_id = makes.div_code and
             vehicles.dealership_id = #{user.dealership.id} and
             not vehicles.draft
      ORDER BY #{order_by}
      LIMIT #{offset}, #{limit}
    SQL

    Vehicle.find_by_sql(vehicle_sql)
  end

  def add_photo(data)
    photo = VehiclePhoto.new_from_upload(:data => data)
    photos << photo
    photos.reload

    return photo
  end

  def set_primary_photo(photo_id)
    photo = photo_by_id(photo_id)
    if photo.nil?
      raise "Could not find photo #{photo_id} in vehicle #{to_param} to make primary"
    end
    self.primary_photo = photo
  end

  def remove_from_inventory
    self.attributes = {
      :dealership_id => nil,
      :title => nil,
      :stock_number => nil,
      :location => nil,
      :actual_cash_value => 0,
      :cost => 0,
      :comments => nil,
      :draft => nil
    }
    self.save(false)
    return self
  end

  def add_available_feature(evd_feature)
    unless has_available_feature?(evd_feature)
      features.create(:name => evd_feature.name,
                      :evd_feature_id => evd_feature.id,
                      :evd_ecc => evd_feature.ecc,
                      :engine => evd_feature.engine,
                      :transmission => evd_feature.transmission,
                      :standard => evd_feature.standard,
                      :optional => evd_feature.optional)
    end
  end

  def has_available_feature?(available_feature)
    features.select do |feature|
      feature.evd_feature_id == available_feature.id
    end.empty? ? false : true
  end

  def transfer_to(other_dealership, cost = 0)
    raise "Attempt to transfer a vehicle to its own dealership" if other_dealership == dealership
    self.remove_from_inventory
    attributes = @attributes.clone
    attributes.delete('created_at')
    attributes.delete('updated_at')
    twin = Vehicle.new(attributes)
    twin.title = true
    twin.draft = false
    twin.dealership = other_dealership
    twin.cost = cost
    twin.save(false)
    twin
  end

  protected
  def photo_by_id(id)
    photos.each do |photo|
      if (photo.id == id)
        return photo
      end
    end
    return nil
  end

end
