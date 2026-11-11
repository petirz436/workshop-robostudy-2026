$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location -LiteralPath $ScriptDir

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   SETUP WORKSPACE" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Direktori Kerja : $ScriptDir"
Write-Host ""

if ($ScriptDir -match "AppData[\\/]Local[\\/]Temp") {
    Write-Host "[PERINGATAN] File ini berjalan langsung dari dalam preview ZIP!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Harap ekstrak file .zip terlebih dahulu:" -ForegroundColor Yellow
    Write-Host "1. Tutup jendela ini."
    Write-Host "2. Klik kanan file .zip -> pilih 'Extract All...' (Ekstrak Semua)."
    Write-Host "3. Buka folder hasil ekstrak, lalu jalankan kembali setup_windows.bat."
    Write-Host "======================================================================" -ForegroundColor Red
    return
}

Write-Host "[1/4] Memeriksa instalasi Python (target 3.12, minimal 3.10+)..." -ForegroundColor Green
$PyCmd = $null

if (Get-Command python -ErrorAction SilentlyContinue) {
    try {
        & python -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $ver = & python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
            $PyCmd = "python"
            Write-Host "Python $ver terdeteksi di PATH [OK]" -ForegroundColor Green
        }
    } catch {}
}

if (-not $PyCmd -and (Get-Command py -ErrorAction SilentlyContinue)) {
    try {
        & py -3.12 -c "import sys; sys.exit(0)" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $PyCmd = "py -3.12"
            Write-Host "Python 3.12 terdeteksi via Python Launcher (py -3.12) [OK]" -ForegroundColor Green
        } else {
            & py -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null
            if ($LASTEXITCODE -eq 0) {
                $ver = & py -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
                $PyCmd = "py"
                Write-Host "Python $ver terdeteksi via Python Launcher (py) [OK]" -ForegroundColor Green
            }
        }
    } catch {}
}

if (-not $PyCmd) {
    Write-Host "Python belum terpasang. Memulai pemasangan Python 3.12 otomatis..." -ForegroundColor Yellow
    Write-Host "(Mohon tunggu, proses download dan instalasi berlangsung 1-3 menit)..."
    
    $installed = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Mengunduh via Windows Package Manager (winget)..."
            & winget install -e --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent
            if ($LASTEXITCODE -eq 0) { $installed = $true }
        } catch {}
    }

    if (-not $installed) {
        try {
            Write-Host "Mengunduh installer resmi Python 3.12 dari python.org..."
            $installerPath = Join-Path $ScriptDir "python_setup.exe"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe" -OutFile $installerPath -UseBasicParsing
            
            Write-Host "Memasang Python (Add to PATH otomatis)..."
            Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_test=0" -Wait
            Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
            $installed = $true
        } catch {
            Write-Host "[ERROR] Gagal mengunduh installer: $_" -ForegroundColor Red
        }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

    if (Get-Command python -ErrorAction SilentlyContinue) {
        $PyCmd = "python"
    } elseif (Get-Command py -ErrorAction SilentlyContinue) {
        $PyCmd = "py"
    } else {
        # Coba cek path default instalasi user
        $defaultPy = Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"
        if (Test-Path $defaultPy) {
            $PyCmd = $defaultPy
        }
    }

    if (-not $PyCmd) {
        Write-Host ""
        Write-Host "[ERROR] Gagal mendeteksi Python setelah instalasi." -ForegroundColor Red
        Write-Host "Silakan unduh manual di https://www.python.org/ (Wajib centang Add python.exe to PATH)." -ForegroundColor Yellow
        Write-Host ""
        return
    }
    Write-Host "Python berhasil dipasang [OK]" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/4] Memeriksa Visual Studio Code..." -ForegroundColor Green
$CodeCmd = $null

if (Get-Command code -ErrorAction SilentlyContinue) {
    $CodeCmd = "code"
} else {
    $paths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"),
        (Join-Path $env:ProgramFiles "Microsoft VS Code\bin\code.cmd")
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $CodeCmd = $p
            break
        }
    }
}

if (-not $CodeCmd) {
    Write-Host "VS Code belum terpasang. Memulai pemasangan VS Code otomatis..." -ForegroundColor Yellow
    $installedCode = $false
    
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Mengunduh VS Code via winget..."
            & winget install -e --id Microsoft.VisualStudioCode --accept-source-agreements --accept-package-agreements --silent
            if ($LASTEXITCODE -eq 0) { $installedCode = $true }
        } catch {}
    }

    if (-not $installedCode) {
        try {
            Write-Host "Mengunduh installer VS Code..."
            $vscodeInstaller = Join-Path $ScriptDir "vscode_setup.exe"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -OutFile $vscodeInstaller -UseBasicParsing
            
            Write-Host "Memasang VS Code..."
            Start-Process -FilePath $vscodeInstaller -ArgumentList "/verysilent", "/mergetasks=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait
            Remove-Item -Path $vscodeInstaller -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Host "[WARNING] Gagal mengunduh VS Code otomatis: $_" -ForegroundColor Yellow
        }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $CodeCmd = "code"
    } else {
        $p = Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"
        if (Test-Path $p) { $CodeCmd = $p }
    }
}

if ($CodeCmd) {
    Write-Host "Visual Studio Code terdeteksi [OK]" -ForegroundColor Green
    Write-Host "Memasang ekstensi Python dan Jupyter di VS Code..."
    try {
        & $CodeCmd --install-extension ms-python.python --force 2>$null
        & $CodeCmd --install-extension ms-toolsai.jupyter --force 2>$null
        Write-Host "Ekstensi VS Code terpasang [OK]" -ForegroundColor Green
    } catch {}
} else {
    Write-Host "Visual Studio Code belum terdeteksi. Silakan pasang ekstensi manual di VS Code nanti." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/4] Menyiapkan environment lokal dan library..." -ForegroundColor Green
$VenvPy = Join-Path $ScriptDir ".venv\Scripts\python.exe"

if (Test-Path $VenvPy) {
    & $VenvPy -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Menghapus .venv lama karena versi Python < 3.10..." -ForegroundColor Yellow
        Remove-Item -Path (Join-Path $ScriptDir ".venv") -Recurse -Force
    }
}

if (-not (Test-Path $VenvPy)) {
    Write-Host "Membuat folder virtual environment (.venv)..."
    if ($PyCmd -eq "py -3.12") {
        & py -3.12 -m venv .venv
    } else {
        & $PyCmd -m venv .venv
    }
}

if (-not (Test-Path $VenvPy)) {
    Write-Host "[ERROR] Gagal membuat virtual environment di dalam folder ini." -ForegroundColor Red
    return
}

Write-Host "Mengunduh dan menginstal OpenCV, NumPy, Matplotlib & IPyKernel (versi terkunci)..." -ForegroundColor Yellow
Write-Host "(Kecepatan tergantung koneksi internet, proses membutuhkan waktu 1-3 menit)..."
& $VenvPy -m pip install --upgrade pip
& $VenvPy -m pip install opencv-python==4.12.0.88 numpy==2.2.6 matplotlib==3.10.3 ipykernel==6.29.5
Write-Host "Dependensi terpasang [OK]" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Menjalankan pengujian sistem..." -ForegroundColor Green
Write-Host ""
& $VenvPy tes_kesiapan.py

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "Proses setup selesai. Tekan sembarang tombol untuk keluar." -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

