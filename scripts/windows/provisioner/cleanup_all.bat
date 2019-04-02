REM Disable Auto Logon
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /d 0 /f

REM Download and Extract Ultra Defrag Utility
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://downloads.sourceforge.net/project/ultradefrag/stable-release/6.1.0/ultradefrag-portable-6.1.0.bin.amd64.zip', 'C:\Windows\Temp\ultradefrag.zip')" <NUL
cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\ultradefrag.zip -oC:\Windows\Temp"

REM Download and Extract Secure Delete Utility
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('http://download.sysinternals.com/files/SDelete.zip', 'C:\Windows\Temp\SDelete.zip')" <NUL
cmd /c ""C:\Program Files\7-Zip\7z.exe" x C:\Windows\Temp\SDelete.zip -oC:\Windows\Temp"

REM Remove 7-Zip Utility
msiexec /qb /x C:\Windows\Temp\7z920-x64.msi

REM Clean Windows Update Download Folder and Recycle the Service
net stop wuauserv
rmdir /S /Q C:\Windows\SoftwareDistribution\Download
mkdir C:\Windows\SoftwareDistribution\Download
net start wuauserv

REM Defragment C Drive
cmd /c C:\Windows\Temp\ultradefrag-portable-6.1.0.amd64\udefrag.exe --optimize --repeat C:

REM Clear Free Space
cmd /c %SystemRoot%\System32\reg.exe ADD HKCU\Software\Sysinternals\SDelete /v EulaAccepted /t REG_DWORD /d 1 /f
cmd /c C:\Windows\Temp\sdelete.exe -q -z C:
