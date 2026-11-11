#!/usr/bin/env bash
set -e

# Pastikan dijalankan dengan bash jika dipanggil via sh
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OS_NAME="$(uname -s)"

is_supported_py() {
    "$1" -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)" 2>/dev/null
}

find_supported_py() {
    for candidate in python3.12 python3.11 python3.10 python3; do
        if command -v "$candidate" >/dev/null 2>&1 && is_supported_py "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

echo "[1/4] Memeriksa Python (target Python 3.12, minimal 3.10+)..."
PY_BIN="$(find_supported_py || true)"

# Jika belum ada Python >= 3.10, lakukan instalasi otomatis
if [ -z "$PY_BIN" ]; then
    if command -v python3 >/dev/null 2>&1; then
        OLD_VER="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo 'unknown')"
        echo "Python bawaan sistem ($OLD_VER) terlalu lama untuk numpy==2.2.6 (butuh Python 3.10+)."
    fi

    if [ "$OS_NAME" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            echo "Memasang Python 3.12 via Homebrew..."
            brew install python@3.12
            PY_BIN="$(find_supported_py || true)"
            if [ -z "$PY_BIN" ] && [ -x "$(brew --prefix)/bin/python3.12" ]; then
                PY_BIN="$(brew --prefix)/bin/python3.12"
            fi
        else
            echo "[ERROR] Homebrew belum terpasang di macOS."
            echo "Silakan pasang installer resmi Python 3.12 di https://www.python.org/downloads/release/python-3127/"
            exit 1
        fi
    elif [ "$OS_NAME" = "Linux" ]; then
        INSTALLED_LINUX=0

        # 1. Coba apt repo biasa
        if command -v apt >/dev/null 2>&1; then
            for pkg in python3.12 python3.11 python3.10; do
                if apt-cache show "$pkg" 2>/dev/null | grep -q "^Package: $pkg$"; then
                    echo "Memasang $pkg via APT..."
                    sudo apt update && sudo apt install -y "$pkg" "${pkg}-venv" python3-pip libgl1 libglib2.0-0 || true
                    PY_BIN="$(find_supported_py || true)"
                    if [ -n "$PY_BIN" ]; then
                        INSTALLED_LINUX=1
                        break
                    fi
                fi
            done
        elif command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y python3.12 python3-pip mesa-libGL glib2 || true
            PY_BIN="$(find_supported_py || true)"
            [ -n "$PY_BIN" ] && INSTALLED_LINUX=1
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm --needed python python-pip mesa glib2 || true
            PY_BIN="$(find_supported_py || true)"
            [ -n "$PY_BIN" ] && INSTALLED_LINUX=1
        fi

        # 2. Jika Linux repo bawaan tidak menyediakan (seperti Ubuntu 20.04), otomatis pasang Python 3.12 standalone via uv
        if [ "$INSTALLED_LINUX" -eq 0 ] && [ -z "$PY_BIN" ]; then
            echo "Mengunduh dan memasang Python 3.12..."
            export CARGO_DIST_FORCE_NONINTERACTIVE=1
            curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || true
            UV_BIN="$HOME/.local/bin/uv"
            if [ -x "$UV_BIN" ]; then
                "$UV_BIN" python install 3.12
                UV_PY_FIND="$("$UV_BIN" python find 3.12 2>/dev/null || true)"
                if [ -n "$UV_PY_FIND" ] && is_supported_py "$UV_PY_FIND"; then
                    PY_BIN="$UV_PY_FIND"
                    INSTALLED_LINUX=1
                fi
            fi
        fi
    fi
fi

if [ -z "$PY_BIN" ]; then
    echo "[ERROR] Gagal memasang Python 3.12 secara otomatis."
    echo "Silakan pasang manual Python 3.12 lalu jalankan kembali skrip ini."
    exit 1
fi

if [ "$OS_NAME" = "Linux" ] && command -v apt >/dev/null 2>&1; then
    PY_VER_SHORT="$($PY_BIN -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    if ! dpkg -s libgl1 >/dev/null 2>&1 || ! dpkg -s libglib2.0-0 >/dev/null 2>&1; then
        echo "Memastikan dependensi libgl1 & libglib2.0-0 terpasang..."
        sudo apt update -y >/dev/null 2>&1 || true
        sudo apt install -y libgl1 libglib2.0-0 >/dev/null 2>&1 || true
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
# OTOMATIS HAPUS .venv lama jika versinya < 3.10
if [ -f ".venv/bin/python" ] && ! is_supported_py ".venv/bin/python"; then
    OLD_VENV_VER="$(./.venv/bin/python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo 'unknown')"
    echo "Menghapus .venv lama (Python $OLD_VENV_VER) karena tidak mendukung numpy==2.2.6..."
    rm -rf .venv
fi

# Buat .venv baru jika belum ada
if [ ! -f ".venv/bin/python" ]; then
    echo "Membuat virtual environment (.venv) baru dengan $($PY_BIN --version)..."
    "$PY_BIN" -m venv .venv 2>/dev/null || {
        # Fallback jika modul venv bawaan belum ada di Python standalone
        if [ -x "$HOME/.local/bin/uv" ]; then
            "$HOME/.local/bin/uv" venv .venv --python "$PY_BIN"
        else
            echo "[ERROR] Gagal membuat .venv."
            exit 1
        fi
    }
fi

echo "Mengunduh dan menginstal OpenCV, NumPy, Matplotlib & IPyKernel..."
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install opencv-python==4.12.0.88 numpy==2.2.6 matplotlib==3.10.3 ipykernel==6.29.5
echo "Dependensi terpasang [OK]"

echo "[4/4] Menjalankan pengujian sistem..."
echo ""
./.venv/bin/python tes_kesiapan.py
