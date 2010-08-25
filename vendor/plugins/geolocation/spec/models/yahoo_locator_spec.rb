require File.dirname(__FILE__) + '/../spec_helper'

describe "A YAHOO locator with mocked out HTTP" do
  include GeolocationFixtures

  before(:each) do
    @locator = YahooLocator.new(:key => "fakekey")
  end

  it "should throw service down error if the HTTP request fails" do
    mock_yahoo_response(@locator, OpenURI::HTTPError.new("503 Service Down", ""))
    lambda {@locator.locate("1600 Amphitheatre Parkway, 94043")}.should raise_error(YahooLocator::ServiceDownError)
  end

  it "should throw an appropriate error for random other errors" do
    mock_yahoo_response(@locator, <<EOS
<?xml version="1.0"?>
<Error xmlns="urn:yahoo:api">
    The following errors were detected:
  <Message>error message</Message>
</Error>
EOS
)
    lambda {@locator.locate("1600 Amphitheatre Parkway, 94043")}.should raise_error(YahooLocator::YahooError)
  end

  it "should throw an appropriate error if the limit is reached" do
    mock_yahoo_response(@locator, <<EOS
<?xml version="1.0"?>
<Error xmlns="urn:yahoo:api"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:noNamespaceSchemaLocation="http://api.yahoo.com/Api/V1/error.xsd">
      The following errors were detected:
    <Message>limit exceeded</Message>
</Error>
EOS
)
    lambda {@locator.locate("1600 Amphitheatre Parkway, 94043")}.should raise_error(YahooLocator::YahooLimitReached)
  end

  it "should handle an ordinary response case" do
    mock_yahoo_response(@locator, <<EOS
<?xml version="1.0"?>
<ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:yahoo:maps" xsi:schemaLocation="urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd"><Result precision="zip"><Latitude>37.7786</Latitude><Longitude>-122.4197</Longitude><Address></Address><City>San Francisco</City><State>CA</State><Zip>94102</Zip><Country>US</Country></Result></ResultSet>
<!-- ws03.search.re2.yahoo.com compressed/chunked Thu May  3 19:02:56 PDT 2007 -->
EOS
)
    location = @locator.locate("94102")
    location.should be_located
    location.address.should be_nil
    location.city.should == "San Francisco"
    location.region.should == "CA"
    location.country.should == "US"
    location.postal_code.should == "94102"
    location.latitude.should be_close(37.7786, 0.001)
    location.longitude.should be_close(-122.4197, 0.001)
    location.accuracy.should == "district"
  end
end

describe "A real YAHOO locator" do
  before(:each) do
    @locator = YahooLocator.new(:key => "geolocation")
  end

  it "should locate correctly" do
    begin
      location = @locator.locate("94102")
      location.city.should match(/San Francisco/i)
      location.region.should == "CA"
      location.country.should == "US"
      location.postal_code.should == "94102"
      location.latitude.should be_close(37.7786, 0.001)
      location.longitude.should be_close(-122.4197, 0.001)
    rescue YahooLocator::ServiceDownError
      puts "Warning: Yahoo locator with key 'geolocation' seems to not be responding."
    end
  end
end

def mock_yahoo_response(locator, expected_response)
  fake_loader = FakeUrlLoader.new(expected_response)
  UrlLoader.should_receive(:new).and_return(fake_loader)
end

