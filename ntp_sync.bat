@echo off

::Prompt to get admin rights
if not "%1"=="am_admin" (
	powershell -Command "Start-Process -Verb RunAs -FilePath '%0' -ArgumentList 'am_admin'"
	exit /b
)

::Search for w32tm service and stop it if it's running
tasklist /FI "IMAGENAME eq w32tm" 2>NUL | find /I /N "w32time">NUL
if "%ERRORLEVEL%"=="0" (
	goto not_running
) else (
	goto continue
)

::Stop the service if it's running
:continue
net stop w32time
w32tm /unregister
w32tm /register

:: Start&Sync system clock with ntp server
:not_running
net start w32time
w32tm /resync /nowait
w32tm /query /peers


IF ERRORLEVEL 0 SET M=0
IF ERRORLEVEL 1 SET M=1
	if %M%==0 (
		echo OK
	) else echo Sync error && pause
exit
