require File.dirname(__FILE__) + '/../spec_helper'

describe "A URL loader with mocked out HTTP" do
  before(:each) do
    @loader = UrlLoader.new("http://test.example.com/foo")
  end

  it "should be able to add parameters" do
    @loader.url.should == "http://test.example.com/foo"
    @loader.add_parameter("key", "value")
    @loader.url.should == "http://test.example.com/foo?key=value"
    @loader.add_parameter("key2", "value2    ")
    @loader.url.should == "http://test.example.com/foo?key=value&key2=value2"
    @loader.add_parameter("key3", "I have spaces and periods. Oh my!")
    @loader.url.should == "http://test.example.com/foo?key=value&key2=value2&key3=I%20have%20spaces%20and%20periods.%20Oh%20my!"
  end

  it "should return an XML root node when load_xml is called" do
    @loader.stub!(:load).and_return('<?xml version="1.0" encoding="UTF-8"?><myxml><foo>bar</foo></myxml>')
    xml = @loader.load_xml
    xml.search("/myxml/foo").text.should == "bar"
  end

  it "should raise bad XML format errors when load_xml is called on non-XML content" do
    @loader.stub!(:load).and_return('Why do you think I am XML?')
    lambda {@loader.load_xml}.should raise_error(MalformedXmlException)
  end
end

describe "A URL loader with a real HTTP" do
  before(:each) do
    @loader = UrlLoader.new("http://www.google.com/")
  end

  it "should load stuff" do
    content = @loader.load
    content.should include("<title>")
  end
end