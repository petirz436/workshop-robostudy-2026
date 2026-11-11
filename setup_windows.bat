@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
echo.
echo ======================================================================
echo Tekan sembarang tombol untuk menutup.
echo ======================================================================
pause >nul
