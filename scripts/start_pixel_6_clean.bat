@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_pixel_6_clean.ps1" %*

endlocal
