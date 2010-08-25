require File.dirname(__FILE__) + '/../spec_helper'

describe Period do

  def check_period(period, expected_end)
    start = Time.local(2000,"jan",1,20,15,1)   #=> Sat Jan 01 8:15:01 pm local time zone, year 2000
    period = Period.new(start, period)
    period.end.should == expected_end
  end

  it "computes two days" do
    check_period(Period::TWO_DAYS, Time.local(2000,1,3,20,15,1))
  end

  it "computes three days" do
    check_period(Period::THREE_DAYS, Time.local(2000,1,4,20,15,1))
  end

  it "computes one week" do
    check_period(Period::ONE_WEEK, Time.local(2000,1,8,20,15,1))
  end

  it "defaults start time to now" do
    Time.stub!(:now).and_return(Time.local(2000,"jan",1,20,15,1))
    period = Period.new(nil, Period::TWO_DAYS)
    period.end.should == Time.local(2000,1,3,20,15,1)
  end

  it "reverse maps days to description" do
    Period.description(Period::TWO_DAYS).should == "2 days"
    Period.description(Period::ONE_WEEK).should == "1 week"
  end

end
