@echo off
setlocal EnableDelayedExpansion

:: Pindah ke direktori tempat file script berada
cd /d "%~dp0"

echo ======================================================================
echo    SETUP WORKSPACE
echo ======================================================================
echo Lokasi folder kerja: "%CD%"
echo.

:: 1. Deteksi apakah dijalankan langsung dari dalam arsip ZIP
echo "%CD%" | findstr /i "AppData\Local\Temp" >nul 2>&1
if %errorlevel% equ 0 (
    echo [PERINGATAN] File ini berjalan langsung dari dalam preview ZIP!
    echo.
    echo Harap ekstrak file .zip terlebih dahulu:
    echo 1. Tutup jendela ini.
    echo 2. Klik kanan file .zip -^> pilih "Extract All..." (Ekstrak Semua).
    echo 3. Buka folder hasil ekstrak, lalu jalankan kembali setup_windows.bat.
    echo ======================================================================
    pause
    exit /b 1
)

:: 2. Pengecekan Python
echo [1/4] Memeriksa instalasi Python...
set "PY_BIN="

where python >nul 2>&1
if %errorlevel% equ 0 (
    set "PY_BIN=python"
) else (
    where py >nul 2>&1
    if %errorlevel% equ 0 (
        set "PY_BIN=py"
    )
)

if not defined PY_BIN (
    echo Python belum terpasang. Memulai pemasangan Python 3.12 otomatis...
    echo (Mohon tunggu, proses download dan instalasi berlangsung 1-3 menit)...
    
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile 'py_setup.exe'"
        if exist py_setup.exe (
            start /wait py_setup.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0
            del py_setup.exe >nul 2>&1
        )
    )

    for /f "tokens=*" %%p in ('powershell -NoProfile -Command "[System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')"') do set "PATH=%%p;%PATH%"
    
    where python >nul 2>&1 && set "PY_BIN=python"
    if not defined PY_BIN (
        where py >nul 2>&1 && set "PY_BIN=py"
    )
    if not defined PY_BIN (
        echo.
        echo [ERROR] Gagal memasang Python secara otomatis.
        echo Silakan pasang manual melalui https://www.python.org/ (Wajib centang Add to PATH).
        echo.
        pause
        exit /b 1
    )
)
echo Python terdeteksi [OK]

:: 3. Pengecekan Visual Studio Code
echo.
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
    echo VS Code belum terpasang. Memasang VS Code otomatis...
    echo (Mohon tunggu hingga proses selesai)...
    
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://update.code.visualstudio.com/latest/win32-x64-user/stable' -OutFile 'vscode_setup.exe'"
        if exist vscode_setup.exe (
            start /wait vscode_setup.exe /verysilent /mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath
            del vscode_setup.exe >nul 2>&1
        )
    )

    if exist "%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd" (
        set "CODE_BIN=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd"
    ) else if exist "%ProgramFiles%\Microsoft VS Code\bin\code.cmd" (
        set "CODE_BIN=%ProgramFiles%\Microsoft VS Code\bin\code.cmd"
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

:: 4. Pembuatan Virtual Environment (.venv) & Library
echo.
echo [3/4] Menyiapkan environment lokal dan library...
if not exist ".venv\Scripts\python.exe" (
    echo Membuat folder virtual environment (.venv)...
    %PY_BIN% -m venv .venv
)

if not exist ".venv\Scripts\python.exe" (
    echo [ERROR] Gagal membuat virtual environment di dalam folder ini.
    pause
    exit /b 1
)

echo Mengunduh dan menginstal OpenCV ^& NumPy...
echo (Kecepatan tergantung koneksi internet, proses membutuhkan waktu 1-2 menit)...
".venv\Scripts\python.exe" -m pip install --upgrade pip
".venv\Scripts\python.exe" -m pip install opencv-python numpy
echo Dependensi terpasang [OK]

:: 5. Pengujian Kesiapan
echo.
echo [4/4] Menjalankan pengujian sistem...
echo.
".venv\Scripts\python.exe" tes_kesiapan.py

echo.
echo ======================================================================
echo Proses setup selesai. Tekan sembarang tombol untuk menutup jendela ini.
echo ======================================================================
pause
