require File.dirname(__FILE__) + '/../spec_helper'

describe BigDecimal, "to_currency" do
  it "should format numbers as currency" do
    BigDecimal("0").to_currency.should == "$0.00"
    BigDecimal("0.006").to_currency.should == "$0.01"
    BigDecimal("0.1").to_currency.should == "$0.10"
    BigDecimal("1.002").to_currency.should == "$1.00"
    BigDecimal("1.02").to_currency.should == "$1.02"
    BigDecimal("123.02").to_currency.should == "$123.02"
    BigDecimal("1234.02").to_currency.should == "$1,234.02"
    BigDecimal("12345.02").to_currency.should == "$12,345.02"
    BigDecimal("123456.02").to_currency.should == "$123,456.02"
    BigDecimal("12345678.02").to_currency.should == "$12,345,678.02"
  end
end

describe String, "to_currency" do
  it "should format string as currency" do
    "0".to_currency.should == "$0.00"
    "0.006".to_currency.should == "$0.01"
    "0.1".to_currency.should == "$0.10"
    "1.002".to_currency.should == "$1.00"
    "1.02".to_currency.should == "$1.02"
    "123.02".to_currency.should == "$123.02"
    "1234.02".to_currency.should == "$1,234.02"
    "12345.02".to_currency.should == "$12,345.02"
    "123456.02".to_currency.should == "$123,456.02"
    "12345678.02".to_currency.should == "$12,345,678.02"
  end
end