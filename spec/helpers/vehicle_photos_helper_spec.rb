require File.dirname(__FILE__) + '/../spec_helper'

module VehicleHelperMethods
  include PhotoHelperMethods

  def setup_vehicle(options = {})
    setup_photos if @photos.nil?

    options_with_defaults = {
      :photo_count => @photos.size
    }.merge(options)
    photo_count = options_with_defaults[:photo_count]

    @vehicle = vehicles(:jetta_vehicle_1)
    photo_count.times { |index| @vehicle.photos << (@photos[index]) }
    @vehicle.photos.reload
  end
  
  def setup_widget_document(setup_options = {}, widget_options = {})
    setup_vehicle setup_options

    @widget_doc = Hpricot(vehicle_photos_widget(@vehicle, widget_options))
  end
end

include VehicleHelperMethods

describe VehiclePhotosHelper, "#thumbnail" do
  it_should_behave_like "SetUpDefaultPhotos"

  it "should produce html with an <img /> with 'src' as the photo's small version" do
    thumbnail = thumbnail(@photos[0], true)

    doc = Hpricot(thumbnail)
    doc.at('//img')['src'].should == @photos[0].versions[:small].url
  end

  it "should produce html with an <img /> with 'id' derived from the photo id" do
    thumbnail = thumbnail(@photos[0], true)

    doc = Hpricot(thumbnail)
    doc.at('//img')['id'].should  == "vehicle_thumb_#{@photos[0].id}"
  end

end

describe VehiclePhotosHelper, "#vehicle_photos_widget" do
  it_should_behave_like "SetUpDefaultPhotos"

  before :each do
    setup_widget_document
  end

  it "should produce html which includes the preview photo div" do
    @widget_doc.at('//div[@id=preview_container]').should_not be(nil)
  end

  it "should produce html which includes the photo thumbnails div" do
    @widget_doc.at('//div[@id=thumbnail_container]').should_not be(nil)
  end

  it "should produce html which includes the controls div" do
    @widget_doc.at('//div[@id=control_container]').should_not be(nil)
  end
end

describe VehiclePhotosHelper, "#vehicle_photos_widget ... the preview photo section" do
  it_should_behave_like "SetUpDefaultPhotos"

  it "should display the default preview photo for a vehicle with no photos" do
    setup_widget_document(:photo_count => 0)
    preview_src.should == '/images/default_vehicle_photo/large.png'
  end

  it "should not have an href for the 'default' preview" do
    setup_widget_document(:photo_count => 0)
    @widget_doc.at("//a[@id='fullsize_link']").should be_nil
  end

  it "should initially display the primary photo as the preview photo for a vehicle with photos" do
    setup_widget_document

    preview_src.should == @vehicle.photos[0].versions[:large].url
  end

  it "should be a hyperlink to a window with the fullsize image" do
    setup_widget_document

    link = preview_link

    link.name.should == "a"
    link[:target].should == "_blank"
    link[:href].should == @vehicle.photos[0].versions[:fullsize].url
  end

  it "should have a tooltip notifying the user that it is a hyperlink" do
    setup_widget_document
    preview_link[:title].should == "Click to enlarge"    
  end

  def preview_img
    return @widget_doc.at('//img[@id=preview_photo]')
  end

  def preview_link
    return preview_img.parent
  end

  def preview_src
    return preview_img[:src]
  end

end

describe VehiclePhotosHelper, "#vehicle_photos_widget ... the thumbnails section" do
  it_should_behave_like "SetUpDefaultPhotos"

  it "should display no thumbnails for a vehicle with no photos" do
    setup_widget_document(:photo_count => 0)

    thumbnail_rows.size.should == 0
  end

  it "should display one thumbnails for a vehicle with one photo" do
    setup_widget_document(:photo_count => 1)

    thumbnail_rows.size.should == 1
    thumbnail_columns(:row => 0).size.should == 2

    thumbnail_src(:row => 0, :column => 0).should == @vehicle.photos[0].versions[:small].url
    thumbnail_img(:row => 0, :column => 1).should be(nil)
  end

  it "should display two thumbnails in one row for a vehicle with two photos" do
    setup_widget_document(:photo_count => 2)

    thumbnail_rows.size.should == 1
    thumbnail_columns(:row => 0).size.should == 2

    thumbnail_src(:row => 0, :column => 0).should == @vehicle.photos[0].versions[:small].url
    thumbnail_src(:row => 0, :column => 1).should == @vehicle.photos[1].versions[:small].url
  end

  it "should display two thumbnails in one row and one thumbnail in the next row for a vehicle with three photos" do
    setup_widget_document(:photo_count => 3)

    thumbnail_rows.size.should == 2
    thumbnail_columns(:row => 0).size.should == 2
    thumbnail_columns(:row => 1).size.should == 2

    thumbnail_src(:row => 0, :column => 0).should == @vehicle.photos[0].versions[:small].url
    thumbnail_src(:row => 0, :column => 1).should == @vehicle.photos[1].versions[:small].url
    thumbnail_src(:row => 1, :column => 0).should == @vehicle.photos[2].versions[:small].url
    thumbnail_img(:row => 1, :column => 1).should be(nil)
  end

  def thumbnail_rows
    return @widget_doc.search('//div[@id=thumbnail_container]//tr')
  end

  def thumbnail_columns(options)
    return thumbnail_rows[options[:row]].search('/td')
  end

  def thumbnail_cell(options)
    return thumbnail_columns(options)[options[:column]]
  end

  def thumbnail_img(options)
    return thumbnail_cell(options).at('/div/img')
  end

  def thumbnail_src(options)
    return thumbnail_img(options)[:src]
  end
end

describe VehiclePhotosHelper, "#vehicle_photos_widget ... the controls section" do
  it_should_behave_like "SetUpDefaultPhotos"

  it "should default to edit mode if no read_only parameter is provided" do
    setup_widget_document

    form = controls_form(:id => "upload_photo")
    form.should_not be(nil)
  end

  it "should have a file upload field in edit mode" do
    setup_widget_document({}, {:read_only => false})

    form = controls_form(:id => "upload_photo")
    form.should_not be(nil)

    file_upload_box = form.at("input[@name='photo']")
    file_upload_box.should_not be(nil)
  end

  it "should have a button labeled Make Primary in edit mode" do
    setup_widget_document({}, {:read_only => false})

    form = controls_form(:id => "make_photo_primary")
    form.should_not be(nil)

    button = form.at('input[@name="commit"]')
    button.should_not be(nil)
    button['value'].should == "Make Primary"
  end

  it "should have a button labeled Delete in edit mode" do
    setup_widget_document({}, {:read_only => false})

    form = controls_form(:id => "delete_photo")
    form.should_not be(nil)

    button = form.at('input[@name="commit"]')
    button.should_not be(nil)
    button['value'].should == "Delete"
  end

  it "should not have a file upload field in read-only mode" do
    setup_widget_document({}, {:read_only => true})
    controls_form(:id => "upload_photo").should be_nil
  end

  it "should not have a Make Primary button in read-only mode" do
    setup_widget_document({}, {:read_only => true})
    controls_form(:id => "make_photo_primary").should be_nil
  end

  it "should not have a Delete button in read-only mode" do
    setup_widget_document({}, {:read_only => true})
    controls_form(:id => "delete_photo").should be_nil
  end
  
  private

  def controls_form(options)
    return @widget_doc.at("//div[@id=control_container]//form[@id=#{options[:id]}]")
  end

end