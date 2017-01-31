@echo off

set "filePath=C:\Dev\lib\"
set "groupId=dev.kkorolyov"

:input
set "confirm="
call:poll
set /p "confirm=Confirm? [Y/N]"
if "%confirm%" == "N" goto input
if "%confirm%" == "n" goto input

cmd /c "mvn install:install-file -DgroupId=%groupId% -DartifactId=%artifactId% -Dversion=%version% -Dfile=%filePath%%file% -Dpackaging=jar"

pause
exit /b %ERRORLEVEL%

:poll
cls
call:printArgs

set /p "filePath=filePath="
cd "%filePath%"
call:printArgs

set /p "file=file=%filePath%"
call:printArgs

set "artifactId="
set "version="

set /p "groupId=groupId="
call:printArgs

set /p "artifactId=artifactId="
call:printArgs

set /p "version=version="
call:printArgs

:printArgs
cls

echo filePath=%filePath%
echo file=%file%
echo groupId=%groupId%
echo artifactId=%artifactId%
echo version=%version%
echo.

exit /b 0