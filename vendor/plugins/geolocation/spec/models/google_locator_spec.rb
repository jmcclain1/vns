require File.dirname(__FILE__) + '/../spec_helper'

describe "A Google locator with mocked out HTTP" do
  include GeolocationFixtures

  before(:each) do
    @locator = GoogleLocator.new(:key => "fakekey")
  end

  it "should throw an appropriate error if the service is down" do
    mock_google_response(@locator, "We're sorry, but google is down right now.  We won't give you XML.")
    lambda {@locator.locate("1600 Amphitheatre Parkway, 94043")}.should raise_error(GoogleLocator::ServiceDown)
  end

  it "should throw an appropriate error if the key is bad" do
    mock_google_response(@locator, <<EOS
<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.1"><Response><name>1600 Amphitheatre Parkway, 94043</name><Status><code>610</code><request>geocode</request></Status></Response></kml>
EOS
)
    lambda {@locator.locate("1600 Amphitheatre Parkway, 94043")}.should raise_error(GoogleLocator::InvalidGoogleKey)
  end

  it "should handle an ordinary response case" do
    mock_google_response(@locator, <<EOS
<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.1"><Response><name>1600 Amphitheatre Parkway, 94043</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>US</CountryNameCode><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Santa Clara</SubAdministrativeAreaName><Locality><LocalityName>Mountain View</LocalityName><Thoroughfare><ThoroughfareName>1600 Amphitheatre Pkwy</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>94043</PostalCodeNumber></PostalCode></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><Point><coordinates>-122.083739,37.423021,0</coordinates></Point></Placemark></Response></kml>
EOS
)
    location = @locator.locate("1600 Amphitheatre Parkway, 94043")
    location.should be_located
    location.address.should == "1600 Amphitheatre Pkwy"
    location.city.should == "Mountain View"
    location.region.should == "CA"
    location.country.should == "US"
    location.postal_code.should == "94043"
    location.latitude.should be_close(37.423021, 0.001)
    location.longitude.should be_close(-122.083739, 0.001)
    location.accuracy.should == "exact"
  end

  it "should handle Canadian addresses" do
    mock_google_response(@locator, <<EOS
<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.1"><Response><name>Edmonton, CA</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>Edmonton, AB, Canada</address><AddressDetails Accuracy="4" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>CA</CountryNameCode><AdministrativeArea><AdministrativeAreaName>AB</AdministrativeAreaName><Locality><LocalityName>Edmonton</LocalityName></Locality></AdministrativeArea></Country></AddressDetails><Point><coordinates>-113.503383,53.532790,0</coordinates></Point></Placemark></Response></kml>
EOS
)
    location = @locator.locate("Edmonton, CA")
    location.should be_located
    location.address.should be_nil
    location.city.should == "Edmonton"
    location.region.should == "AB"
    location.country.should == "CA"
    location.postal_code.should be_nil
    location.latitude.should be_close(53.532790, 0.001)
    location.longitude.should be_close(-113.503383, 0.001)
    location.accuracy.should == "city"
  end

  it "should handle German addresses" do
    mock_google_response(@locator, <<EOS
<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://earth.google.com/kml/2.1"><Response><name>18 Baumschulenweg,Berlin,DE</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>Baumschulenstra§e 18, 12437 Baumschulenweg, Berlin, Germany</address><AddressDetails Accuracy="8" xmlns="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"><Country><CountryNameCode>DE</CountryNameCode><AdministrativeArea><AdministrativeAreaName>Berlin</AdministrativeAreaName><SubAdministrativeArea><SubAdministrativeAreaName>Berlin</SubAdministrativeAreaName><Locality><LocalityName>Berlin</LocalityName><DependentLocality><DependentLocalityName>Baumschulenweg</DependentLocalityName><Thoroughfare><ThoroughfareName>Baumschulenstra§e 18</ThoroughfareName></Thoroughfare><PostalCode><PostalCodeNumber>12437</PostalCodeNumber></PostalCode></DependentLocality></Locality></SubAdministrativeArea></AdministrativeArea></Country></AddressDetails><Point><coordinates>13.487166,52.465695,0</coordinates></Point></Placemark></Response></kml>
EOS
)
    location = @locator.locate("18 Baumschulenweg,Berlin,DE")
    location.should be_located
    location.address.should == "Baumschulenstra§e 18"
    location.city.should == "Berlin"
    location.region.should == "Berlin"
    location.country.should == "DE"
    location.postal_code.should == "12437"
    location.latitude.should be_close(52.465695, 0.001)
    location.longitude.should be_close(13.487166, 0.001)
    location.accuracy.should == "exact"
  end

  it "should handle funky address namespaces" do
    mock_google_response(@locator, <<EOS
<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://earth.google.com/kml/2.1\"><Response><name>94127</name><Status><code>200</code><request>geocode</request></Status><Placemark><address>San Francisco, CA 94127, USA</address><AddressDetails Accuracy=\"5\" xmlns=\"urn:oasis:names:tc:ciq:xsdschema:xAL:2.0\"><Country><CountryNameCode>US</CountryNameCode><AdministrativeArea><AdministrativeAreaName>CA</AdministrativeAreaName><Locality><LocalityName>San Francisco</LocalityName><PostalCode><PostalCodeNumber>94127</PostalCodeNumber></PostalCode></Locality></AdministrativeArea></Country></AddressDetails><Point><coordinates>-122.457116,37.735385,0</coordinates></Point></Placemark></Response></kml>
EOS
)
    location = @locator.locate("94127")
    location.should be_located
    location.city.should == "San Francisco"
    location.accuracy.should == "district"
  end
end

describe "A real google locator" do
  before(:each) do
    @locator = GoogleLocator.new(:google_key => 'ABQIAAAAlXT8ShvNVWM6Ep1f1qh3vRRaFxhFEJMkRDDY9WmhGr5TY50NyBT-GgGrhEplFCIDnLczshtF7CsJEA')
  end

  it "should locate correctly" do
    location = @locator.locate("83 Eddy Street, San Francisco, CA")
    location.latitude.should be_close(37.784295, 0.001)
    location.longitude.should be_close(-122.409026, 0.001)
  end
end

def mock_google_response(locator, expected_response)
  fake_loader = FakeUrlLoader.new(expected_response)
  UrlLoader.should_receive(:new).and_return(fake_loader)
end

