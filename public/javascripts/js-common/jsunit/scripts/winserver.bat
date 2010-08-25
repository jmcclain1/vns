SET JSUNIT_DIR=c:\dev\workspace\jsunit

C:\ant\bin\ant.bat -f %JSUNIT_DIR%\build.xml -Djsunit.timeoutSeconds=1200 -Djsunit.browserFileNames="C:\Program Files\Internet Explorer\IEXPLORE.EXE,C:\Program Files\Mozilla Firefox\firefox.exe" -Djsunit.url=http://dummyurl start_server
