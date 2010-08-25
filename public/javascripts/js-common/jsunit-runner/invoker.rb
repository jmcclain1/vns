dir = File.dirname(__FILE__)

begin
  require "#{dir}/jsunit_runner"
rescue LoadError
  require 'rubygems'
  require "#{dir}/jsunit_runner"
end

default_browser_cmd = if (RUBY_PLATFORM =~ /[^r]win/) 
  'C:\Program Files\Mozilla Firefox\firefox.exe'
  elsif (RUBY_PLATFORM =~ /darwin/i)
    "firefox -P Test"
  else
    "firefox"
  end

runner = JsunitRunner.application
runner.browser_cmd = ENV['JSUNIT_BROWSER_CMD'] || default_browser_cmd
runner.app_host = ENV['JSUNIT_APP_HOST'] || "localhost"
runner.app_port = ENV['JSUNIT_APP_PORT'] || "3000"
runner.test_page = ENV['JSUNIT_TEST_PAGE'] || "/javascripts/test-pages/suite.html"
runner.run
