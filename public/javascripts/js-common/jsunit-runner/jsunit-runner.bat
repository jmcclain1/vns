REM Modify these environment variables to change behavior.  For example, you can use a specific test file instead of the suite
REM If you only want to run IE, delete the firefox invocation below.  

REM TODO: this doesn't automatically close the first browser

set JSUNIT_TEST_PAGE=/javascripts/test-pages/suite.html
set JSUNIT_APP_HOST=localhost
set JSUNIT_APP_PORT=80

set JSUNIT_BROWSER_CMD=C:\Program Files\Internet Explorer\iexplore.exe
start ruby invoker.rb
set JSUNIT_BROWSER_CMD=C:\Program Files\Mozilla Firefox\firefox.exe
start ruby invoker.rb
exit
