# Panduan Setup Laptop — Workshop Computer Vision RoboStudy 2026

Panduan konfigurasi environment laptop peserta (Windows, macOS, dan Linux) agar siap digunakan saat workshop.

---

## 📥 Langkah 0: Mengunduh Berkas Repository

1. Klik tombol **`<> Code`** berwarna hijau di kanan atas repositori ini.
2. Pilih opsi **`Download ZIP`**.
3. Buka folder `Downloads` pada perangkat Anda, lalu ekstrak arsip `.zip`:
   - **Windows:** Klik kanan berkas -> pilih **Extract All...** -> klik **Extract**.
   - **macOS:** Klik 2x berkas `.zip`.
   - **Linux:** Klik kanan -> pilih **Extract Here**.
4. Seluruh proses instalasi wajib dijalankan dari dalam folder hasil ekstraksi.

---

## 📌 INSTRUKSI WAJIB SETELAH SELESAI SETUP

1. **Ambil Tangkapan Layar (Screenshot):**  
   Setelah pengujian selesai dan menampilkan status `ALL CORE CHECKS PASSED`, ambil tangkapan layar jendela terminal atau pop-up konfirmasi.
2. **Kirimkan Bukti Kesiapan:**  
   Kirimkan screenshot tersebut ke grup WhatsApp peserta / link konfirmasi panitia (target selesai H-2).
3. **Pusat Bantuan:**  
   Jika menemukan kendala teknis pada tahap mana pun, tanyakan di grup WhatsApp peserta dengan melampirkan tangkapan layar pesan galat.

---

## ⚙️ Spesifikasi Kebutuhan Sistem

- **Editor**: Visual Studio Code (beserta ekstensi Python & Jupyter)
- **Runtime**: Python 3.11 atau 3.12 (64-bit)
- **Library**: `opencv-python`, `numpy`
- **Perangkat**: Laptop dengan webcam / kamera bawaan (tersedia opsi file video contoh jika kamera fisik tidak tersedia)

---

## 🚀 METODE 1: Setup Otomatis

Skrip otomatis akan memeriksa dependensi sistem, mengunduh komponen yang belum terpasang, mengonfigurasi virtual environment lokal, dan menjalankan verifikasi sistem.

### 🪟 Windows
1. Buka folder hasil ekstraksi melalui **File Explorer**.
2. Klik ganda berkas:
   ```text
   setup_windows.bat
   ```
   *(Jika muncul dialog Windows SmartScreen, klik **More info** -> **Run anyway**).*
3. Tunggu hingga proses selesai dan menampilkan status `ALL CORE CHECKS PASSED`.
4. Ambil tangkapan layar hasil verifikasi.

---

### 🍎 macOS
1. Buka aplikasi **Terminal** (tekan `Cmd + Spasi`, ketik `Terminal`, lalu tekan **Enter**).
2. Ketik `bash ` (tulis kata bash lalu beri **satu spasi**).
3. Seret (*drag and drop*) berkas `setup_unix.sh` dari Finder ke dalam jendela Terminal tersebut.
4. Tekan **Enter**, tunggu hingga verifikasi selesai, lalu simpan tangkapan layar hasilnya.

---

### 🐧 Linux
1. Buka **Terminal** (tekan shortcut `Ctrl + Alt + T`).
2. Masuk ke folder proyek dengan mengetik perintah:
   ```bash
   cd ~/Downloads/workshop-robostudy-2026-main
   ```
   *(Atau klik kanan area kosong di dalam folder proyek pada file manager -> pilih **Open in Terminal**).*
3. Jalankan skrip setup:
   ```bash
   bash setup_unix.sh
   ```
4. Tunggu hingga verifikasi selesai dan simpan tangkapan layar hasilnya.

---

## 💻 METODE 2: Setup Manual Langkah demi Langkah

Gunakan metode ini jika Anda ingin melakukan instalasi mandiri langkah demi langkah.

---

### Tahap 1: Instalasi Software Dasar (Jika Belum Terpasang)

Pastikan kedua perangkat lunak berikut sudah terpasang di laptop Anda sebelum membuka terminal:

#### 1. Visual Studio Code (VS Code)
- **Tautan Unduh Resmi:** [code.visualstudio.com/Download](https://code.visualstudio.com/Download)
- **Cara Instalasi:**
  - **Windows:** Unduh installer `User Installer 64-bit` -> buka file instalasi -> pilih *I accept the agreement* -> klik *Next* hingga selesai -> klik *Install*.
  - **macOS:** Unduh berkas `.zip` untuk Mac -> ekstrak -> seret aplikasi `Visual Studio Code.app` ke dalam folder `Applications`.
  - **Linux:** Unduh paket `.deb` (Ubuntu/Debian) atau `.rpm` (Fedora), lalu instal melalui terminal atau package manager.

#### 2. Python 3.12 (64-bit)
- **Tautan Unduh Resmi:** [python.org/downloads/release/python-3127](https://www.python.org/downloads/release/python-3127/)
  - Windows: [Windows installer (64-bit)](https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe)
  - macOS: [macOS 64-bit universal2 installer](https://www.python.org/ftp/python/3.12.7/python-3.12.7-macos11.pkg)
- **Cara Instalasi:**
  - 🚨 **KHUSUS PENGGUNA WINDOWS (SANGAT PENTING):**  
    Saat jendela instalasi Python pertama kali terbuka, **WAJIB CENTANG** kotak di bagian paling bawah bertuliskan:  
    ☑️ **`Add python.exe to PATH`**  
    Setelah dicentang, barulah klik tombol **Install Now**.  
    *(Jika kotak ini lupa dicentang, terminal tidak akan mengenali perintah python).*
  - **macOS:** Buka file `.pkg` yang telah diunduh -> klik *Continue* -> *Agree* -> *Install* hingga selesai.
  - **Linux (Ubuntu/Debian):** Cukup pasang via terminal:  
    `sudo apt update && sudo apt install -y python3 python3-venv python3-pip libgl1 libglib2.0-0`

---

### Tahap 2: Konfigurasi Virtual Environment & Library (Via Terminal)

Setelah Python dan VS Code terpasang di laptop, lanjutkan konfigurasi workspace sesuai sistem operasi Anda:

#### 🪟 Panduan Terminal Windows (Command Prompt / PowerShell)

Buka aplikasi **Command Prompt** (tekan tombol Windows, ketik `cmd`, lalu tekan Enter) atau **PowerShell**, kemudian jalankan instruksi berikut secara berurutan:

#### 1. Masuk ke Direktori Proyek
Sesuaikan dengan folder hasil ekstraksi di laptop Anda (bawaan nama folder dari GitHub adalah `workshop-robostudy-2026-main`):
```cmd
cd "%USERPROFILE%\Downloads\workshop-robostudy-2026-main"
```
*(Catatan: Jika Anda mengekstrak ke folder bernama lain atau lokasi berbeda, gunakan `cd /d "PATH_FOLDER_ANDA"`).*

#### 2. Membuat Virtual Environment (.venv)
Membuat lingkungan Python terisolasi di dalam folder:
```cmd
python -m venv .venv
```

#### 3. Memasang Dependensi Pustaka
Mengunduh dan memasang OpenCV serta NumPy ke dalam virtual environment:
```cmd
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install opencv-python numpy
```

#### 4. Memasang Ekstensi Visual Studio Code
Memasang dependensi ekstensi resmi Microsoft untuk VS Code:
```cmd
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

#### 5. Menjalankan Verifikasi Sistem
Menguji fungsi komputasi pustaka dan akses kamera:
```cmd
.\.venv\Scripts\python.exe tes_kesiapan.py
```

---

### 🍎 macOS & 🐧 Linux

#### Cara Membuka Terminal & Berpindah Folder:
- **macOS:** Tekan `Cmd + Spasi`, ketik `Terminal`, lalu tekan **Enter**.
- **Linux:** Tekan kombinasi tombol `Ctrl + Alt + T` (atau klik kanan area kosong di dalam folder proyek pada file manager lalu pilih **Open in Terminal**).

Setelah Terminal terbuka, jalankan instruksi berikut secara berurutan:

#### 1. Masuk ke Direktori Proyek
Salin dan jalankan perintah perpindahan folder berikut:
```bash
cd "$HOME/Downloads/workshop-robostudy-2026-main"
```
*(Catatan: Jika folder berada di lokasi lain, ketik `cd ` lalu seret folder tersebut dari Finder / File Manager ke dalam jendela Terminal).*

#### 2. Membuat Virtual Environment (.venv)
```bash
python3 -m venv .venv
```

#### 3. Memasang Dependensi Pustaka
```bash
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install opencv-python numpy
```

#### 4. Memasang Ekstensi Visual Studio Code
```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
```

#### 5. Menjalankan Verifikasi Sistem
```bash
./.venv/bin/python tes_kesiapan.py
```

---

## 🔧 Panduan Penanganan Masalah (Troubleshooting)

| Gejala / Pesan Galat | Penyebab | Solusi |
| :--- | :--- | :--- |
| **`The system cannot find the path specified` saat `cd`** | Nama atau lokasi folder tidak sesuai dengan perintah terminal. | Buka folder di File Explorer, salin path lengkap dari bilah alamat, lalu gunakan `cd /d "PATH_YANG_DISALIN"`. |
| **Jendela instalasi otomatis langsung tertutup** | Berkas dijalankan dari dalam preview file zip tanpa diekstrak terlebih dahulu. | Ekstrak berkas `.zip` terlebih dahulu, lalu jalankan kembali skrip dari dalam folder hasil ekstraksi. |
| **Pop-up dialog: `Windows protected your PC`** | Fitur proteksi Windows SmartScreen pada berkas skrip yang baru diunduh. | Klik **More info**, kemudian klik **Run anyway**. |
| **`'python' is not recognized as an internal or external command`** | Python belum terpasang atau variabel PATH belum terkonfigurasi. | Buka installer resmi Python -> pilih **Modify** -> centang **Add Python to environment variables** -> selesaikan instalasi. |
| **`Camera: Not detected / disabled by privacy switch`** | Shutter fisik webcam tertutup atau izin akses aplikasi dinonaktifkan sistem. | Buka penutup kamera fisik atau aktifkan perizinan webcam pada menu pengaturan privasi sistem operasi. |
| **`No module named 'cv2'` pada file Notebook (.ipynb)** | VS Code belum menggunakan interpreter dari `.venv`. | Klik tombol **Select Kernel** pada pojok kanan atas editor notebook -> pilih **Python Environments...** -> arahkan ke **.venv**. |
| **`ImportError: libGL.so.1` (Linux)** | Dependensi rendering sistem Linux belum terpasang. | Jalankan perintah terminal: `sudo apt update && sudo apt install -y libgl1 libglib2.0-0`. |

---

## 📋 Prosedur Hari H

1. Peserta yang mengalami kendala teknis dapat melapor ke meja panitia/asisten pada rentang waktu **07.00 – 07.30 WIB**.
2. Jika kendala sistem pada perangkat peserta membutuhkan penanganan lebih dari 15 menit, peserta akan diarahkan menggunakan metode **Pair Programming** (bergabung dengan rekan satu meja yang telah terverifikasi) agar alur penyampaian materi workshop dapat dimulai tepat waktu.
