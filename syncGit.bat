@echo off
set git="C:\Tools\Git\bin\git.exe"
set sources=C:\Documents\Money C:\Documents\School\SJSU

for %%a in (%sources%) do (
	echo %%a

	%git% -C %%a pull
	
	%git% -C %%a add .
	set msg='date +"%%Y-%%m-%%d"'
	%git% -C %%a commit -m "Sync %msg%"
	%git% -C %%a push
)
pause
exit /b %ERRORLEVEL%
