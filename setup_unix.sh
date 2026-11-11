#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OS_NAME="$(uname -s)"

echo "[1/4] Memeriksa Python..."
PY_BIN=""

if command -v python3.12 >/dev/null 2>&1; then
    PY_BIN="python3.12"
elif command -v python3 >/dev/null 2>&1; then
    PY_BIN="python3"
fi

if [ -z "$PY_BIN" ]; then
    echo "Python 3 belum terpasang. Memulai pemasangan..."
    if [ "$OS_NAME" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            echo "Menginstal Python via Homebrew (1-3 menit)..."
            brew install python@3.12
            PY_BIN="python3"
        else
            echo "[ERROR] Homebrew belum terpasang."
            echo "Unduh Python manual di: https://www.python.org/downloads/macos/"
            exit 1
        fi
    elif [ "$OS_NAME" = "Linux" ]; then
        echo "Menginstal Python dan dependensi sistem (masukkan password laptop jika diminta)..."
        if command -v apt >/dev/null 2>&1; then
            sudo apt update && sudo apt install -y python3 python3-venv python3-pip libgl1 libglib2.0-0
            PY_BIN="python3"
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y python3 python3-pip mesa-libGL glib2
            PY_BIN="python3"
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm --needed python python-pip mesa glib2
            PY_BIN="python3"
        fi
    fi
else
    # Cek apakah venv dan OpenGL sudah ada di Linux
    if [ "$OS_NAME" = "Linux" ] && command -v apt >/dev/null 2>&1; then
        if ! dpkg -s libgl1 >/dev/null 2>&1 || ! dpkg -s python3-venv >/dev/null 2>&1; then
            echo "Memasang dependensi sistem python3-venv & libgl1 (masukkan password laptop jika diminta)..."
            sudo apt update && sudo apt install -y python3-venv libgl1 libglib2.0-0
        fi
    fi
fi
echo "Python terdeteksi ($($PY_BIN --version)) [OK]"

echo "[2/4] Memeriksa Visual Studio Code..."
CODE_BIN=""
if command -v code >/dev/null 2>&1; then
    CODE_BIN="code"
elif [ "$OS_NAME" = "Darwin" ] && [ -d "/Applications/Visual Studio Code.app" ]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    CODE_BIN="code"
fi

if [ -z "$CODE_BIN" ]; then
    echo "VS Code belum terpasang. Memulai pemasangan..."
    if [ "$OS_NAME" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        echo "Menginstal VS Code via Homebrew Cask..."
        brew install --cask visual-studio-code
        export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        CODE_BIN="code"
    elif [ "$OS_NAME" = "Linux" ] && command -v snap >/dev/null 2>&1; then
        echo "Menginstal VS Code via Snap (masukkan password laptop jika diminta)..."
        sudo snap install --classic code || true
        CODE_BIN="code"
    fi
fi

if command -v code >/dev/null 2>&1; then
    echo "Memasang ekstensi Python dan Jupyter di VS Code..."
    code --install-extension ms-python.python --force >/dev/null 2>&1 || true
    code --install-extension ms-toolsai.jupyter --force >/dev/null 2>&1 || true
    echo "Ekstensi VS Code terpasang [OK]"
fi

echo "[3/4] Menyiapkan environment dan library..."
if [ ! -f ".venv/bin/python" ]; then
    echo "Membuat virtual environment (.venv) otomatis..."
    $PY_BIN -m venv .venv
fi

echo "Mengunduh dan menginstal OpenCV, NumPy, Matplotlib & IPyKernel (versi terkunci)..."
echo "(Kecepatan tergantung koneksi internet, proses membutuhkan waktu 1-3 menit)..."
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install opencv-python==4.12.0.88 numpy==2.2.6 matplotlib==3.10.3 ipykernel==6.29.5
echo "Dependensi terpasang [OK]"

echo "[4/4] Menjalankan pengujian sistem..."
echo ""
./.venv/bin/python tes_kesiapan.py
