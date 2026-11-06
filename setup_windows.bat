@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

:: 1. Deteksi apakah dijalankan langsung dari dalam ZIP (Temp folder)
echo "%CD%" | findstr /i "AppData\Local\Temp" >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo [PERINGATAN] FILE BERJALAN DARI DALAM FILE ZIP!
    echo.
    echo Anda belum mengekstrak file zip ini.
    echo 1. Tutup jendela ini.
    echo 2. Klik kanan file .zip -> pilih "Extract All..." (Ekstrak Semua).
    echo 3. Buka folder hasil ekstrak, lalu jalankan kembali setup_windows.bat.
    echo ======================================================================
    echo.
    pause
    exit /b 1
)

echo [1/4] Memeriksa Python...
set "PY_BIN="

where python >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_BIN=python"
) else (
    where py >nul 2>&1
    if %errorlevel% equ 0 set "PY_BIN=py"
)

if not defined PY_BIN (
    echo Python belum terpasang. Mengunduh dan memasang Python otomatis...
    echo (Mohon tunggu, proses ini membutuhkan waktu 1-3 menit)...
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
    ) else (
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile 'py_setup.exe'"
        start /wait py_setup.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
        del py_setup.exe >nul 2>&1
    )
    for /f "tokens=*" %%p in ('powershell -NoProfile -Command "[System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')"') do set "PATH=%%p;%PATH%"
    where python >nul 2>&1 && set "PY_BIN=python"
    if not defined PY_BIN (
        where py >nul 2>&1 && set "PY_BIN=py"
    )
    if not defined PY_BIN (
        echo [ERROR] Gagal memasang Python secara otomatis.
        echo Silakan pasang manual melalui https://www.python.org/ (Wajib centang Add to PATH).
        pause
        exit /b 1
    )
)
echo Python terdeteksi [OK]

echo [2/4] Memeriksa Visual Studio Code...
set "CODE_BIN="
where code >nul 2>&1
if %errorlevel% equ 0 (
    set "CODE_BIN=code"
) else (
    if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" (
        set "CODE_BIN=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
    ) else if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" (
        set "CODE_BIN=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
    )
)

if not defined CODE_BIN (
    echo VS Code belum terpasang. Mengunduh dan memasang VS Code...
    echo (Mohon tunggu, proses instalasi sedang berjalan)...
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
    ) else (
        powershell -NoProfile -Command "Invoke-WebRequest -Uri 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' -OutFile 'vscode_setup.exe'"
        start /wait vscode_setup.exe /verysilent /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath
        del vscode_setup.exe >nul 2>&1
    )
    if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" (
        set "CODE_BIN=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
    ) else (
        where code >nul 2>&1 && set "CODE_BIN=code"
    )
)
echo Visual Studio Code terdeteksi [OK]

if defined CODE_BIN (
    echo Memasang ekstensi Python dan Jupyter di VS Code...
    call "%CODE_BIN%" --install-extension ms-python.python --force >nul 2>&1
    call "%CODE_BIN%" --install-extension ms-toolsai.jupyter --force >nul 2>&1
    echo Ekstensi VS Code terpasang [OK]
)

echo [3/4] Menyiapkan environment dan library...
if not exist ".venv\Scripts\python.exe" (
    echo Membuat virtual environment (.venv)...
    %PY_BIN% -m venv .venv
)

echo Mengunduh dan menginstal OpenCV & NumPy...
echo (Kecepatan tergantung koneksi internet, proses membutuhkan waktu 1-2 menit)...
".venv\Scripts\python.exe" -m pip install --upgrade pip
".venv\Scripts\python.exe" -m pip install opencv-python numpy
echo Dependensi terpasang [OK]

echo [4/4] Menjalankan pengujian sistem...
echo.
".venv\Scripts\python.exe" tes_kesiapan.py

pause
