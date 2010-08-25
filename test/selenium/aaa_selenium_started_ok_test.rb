require File.dirname(__FILE__) + "/selenium_helper"

class AAASeleniumStartedOkTest < VnsSeleniumTestCase

  def test_started
    @default_timeout=60000
    open "/"
    assert_text_present("Log in", {:timeout=>120.seconds})
  end
end
