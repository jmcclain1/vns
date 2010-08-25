dir = File.dirname(__FILE__)

require File.expand_path(dir + "/../../vendor/plugins/pivotal_core_bundle/lib/test_framework_bootstrap")
#Test::Unit::TestCase.fixture_path = Pivotal::RailsTestCase.fixture_path

#require dir + "/../test_helper"
require "seleniumrc_fu/selenium_helper"
require dir + "/vns_selenium_test_case"

#Pivotal::SeleniumConfiguration.browsers = ["custom /opt/firefox/firefox-bin"]

def within_frame(frame_index, &block)
  # This logic should be changed to leverage selectFrame method in Selenium post rev 1115.
  select_frame_js =<<-js
    var frame = selenium.browserbot.getCurrentWindow().frames[#{frame_index}];
    selenium.browserbot.oldGetCurrentWindow = selenium.browserbot.getCurrentWindow;
    selenium.browserbot.getCurrentWindow = function() {
      return frame;
    }
  js

  get_eval(select_frame_js)
  begin
    yield
  ensure
    get_eval("selenium.browserbot.getCurrentWindow = selenium.browserbot.oldGetCurrentWindow;")
  end
end

def assert_thumbnail_present(index, filename)
  thumbnail_image_src = <<-END
    selenium.browserbot.getCurrentWindow().document.getElementById('thumbnail_#{index}').firstChild.firstChild.src;
  END

  assert_pattern_matches_result("/small/#{filename}") { selenium.get_eval(thumbnail_image_src) }
end

def assert_pattern_matches_result(pattern, &block)
  wait_for :timeout => 10, :message => "Patterns mismatch: #{pattern}" do
    begin
      content = yield
      content.match(pattern)
    rescue
      # Selenium will throw an exception if the specified JavaScript returns an error (such as attempting to
      # dereference a null element).  Absorb these errors here to prevent the test failing before the timeout.
      return false
    end
  end
end

def assert_preview_present(filename)
  link_src = <<-END
    selenium.browserbot.getCurrentWindow().document.getElementById('fullsize_link').href;
  END

  image_src = <<-END
    selenium.browserbot.getCurrentWindow().document.getElementById('preview_photo').src;
  END

  assert_pattern_matches_result("/fullsize/#{filename}") { selenium.get_eval(link_src) }
  assert_pattern_matches_result("/large/#{filename}") { selenium.get_eval(image_src) }
end

def click_thumbnail(index)
  js = <<-END
    selenium.browserbot.getCurrentWindow().document.getElementById('thumbnail_#{index}').firstChild.firstChild.onclick();
  END

  selenium.get_eval(js)
end

def submit_form_in_frame(form_id)
  form_submit = <<-END
    selenium.browserbot.getCurrentWindow().document.getElementById('#{form_id}').submit();
  END

  selenium.get_eval(form_submit);
end
