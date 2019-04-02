REM Install VMware Tools
cmd /c D:\setup.exe /S /v"/qn REBOOT=R\"

set errorcode=%errorlevel%

if %errorcode%==3010 (
  echo VMware Tools Installed Successfully, Reboot Required
  exit /b 0
) else (
  exit /b %errorcode%
)
