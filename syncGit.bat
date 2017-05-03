@echo off
set git="C:\Tools\Git\bin\git.exe"

@echo on
%git% -C C:\Documents\Money pull
%git% -C C:\Documents\School\SJSU pull

@echo off
pause
exit /b %ERRORLEVEL%

