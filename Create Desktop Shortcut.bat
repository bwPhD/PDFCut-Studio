@echo off
setlocal
set "ROOT=%~dp0"
set "TARGET=%ROOT%PDFCut Studio.vbs"
set "SHORTCUT=%USERPROFILE%\Desktop\PDFCut Studio.lnk"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%TARGET%'; $s.WorkingDirectory='%ROOT%'; $s.Description='PDFCut Studio portable PDF cropper'; $s.Save()"
echo Desktop shortcut created: %SHORTCUT%
pause
endlocal
