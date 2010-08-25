dir = File.dirname(__FILE__)
require "#{dir}/../test_helper"

class ClockTest < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_now__time_frozen_under_test
    now = Time.now
    flexstub(Time).should_receive(:now).and_return(now)
    first_time = Clock.now
    flexstub(Time).should_receive(:now).and_return(now + 1)
    assert_equal first_time, Clock.now
  end
end