# Panduan Setup Laptop — Workshop Computer Vision RoboStudy 2026

Panduan konfigurasi environment laptop peserta (Windows, macOS, dan Linux) agar siap digunakan saat workshop.

---

## 📥 Cara Mengunduh Berkas Repository Ini

Bagi peserta yang belum terbiasa menggunakan Git, cara termudah adalah mengunduh file `.zip` langsung dari halaman GitHub ini:

1. Klik tombol hijau bertuliskan **`<> Code`** di bagian atas halaman repositori ini.
2. Pada menu dropdown yang muncul, klik opsi paling bawah: **`Download ZIP`**.
3. Buka folder `Downloads` di laptopmu, lalu **ekstrak file `.zip` tersebut**:
   - **Windows:** Klik kanan file `.zip` $\rightarrow$ pilih **Extract All...** $\rightarrow$ klik **Extract**.
   - **macOS:** Klik 2x file `.zip` hingga menjadi folder biasa.
   - **Linux:** Klik kanan $\rightarrow$ **Extract Here** (atau jalankan perintah `unzip`).
4. Masuk ke dalam folder hasil ekstraksi, lalu lanjutkan ke langkah instalasi di bawah.

> ⚠️ **PENTING:** Jangan langsung menjalankan file skrip setup dari dalam preview file `.zip` tanpa mengekstraknya terlebih dahulu!

---

## 📌 INSTRUKSI WAJIB SETELAH SELESAI SETUP

1. **Ambil Tangkapan Layar (Screenshot):**  
   Setelah pengujian selesai dan menampilkan status `ALL CORE CHECKS PASSED`, ambil screenshot jendela terminal atau kotak pop-up tersebut secara utuh sebagai bukti kesiapan laptop Anda.
2. **Kirimkan Bukti Kesiapan:**  
   Kirimkan screenshot tersebut ke grup WhatsApp peserta atau form konfirmasi yang disediakan panitia sebelum batas waktu yang ditentukan (target H-2).
3. **Pusat Bantuan & Kendala:**  
   Jika menemukan kendala pada langkah mana pun, **segera tanyakan di grup WhatsApp peserta**. Jangan menunggu hingga hari H agar dapat dipandu langsung oleh tim asisten.

---

## Spesifikasi Kebutuhan

- **Editor**: Visual Studio Code (beserta ekstensi Python & Jupyter)
- **Runtime**: Python 3.11 atau 3.12 (64-bit)
- **Library**: `opencv-python`, `numpy`
- **Perangkat**: Laptop dengan webcam / kamera bawaan (opsional, tersedia opsi file video)

---

## Metode 1: Setup Otomatis (Direkomendasikan)

Skrip otomatis akan mendeteksi status instalasi laptop, mengunduh komponen yang belum terpasang, mengonfigurasi virtual environment, dan langsung menjalankan uji verifikasi software serta webcam laptop.

### 🪟 Windows
1. Pastikan file `.zip` materi sudah diekstrak (**Klik Kanan > Extract All...**).
2. Masuk ke folder hasil ekstrak, lalu klik ganda file:
   ```text
   setup_windows.bat
   ```
   > **Catatan Windows SmartScreen:** Jika muncul pop-up biru *"Windows protected your PC"*, klik tulisan **"More info"** lalu klik tombol **"Run anyway"**.
3. Tunggu proses instalasi hingga muncul notifikasi dan status `ALL CORE CHECKS PASSED`.
4. Ambil screenshot hasilnya dan kirimkan ke grup peserta.

---

### 🍎 macOS
Buka aplikasi **Terminal** (`Cmd + Spasi`, ketik `Terminal`), lalu seret file `setup_unix.sh` ke dalam Terminal dengan cara:
1. Ketik `bash ` (pastikan ada satu spasi setelah kata bash).
2. Seret (*drag and drop*) file `setup_unix.sh` dari Finder ke dalam jendela Terminal.
3. Tekan **Enter**.

*(Atau masuk ke folder proyek via terminal lalu jalankan: `bash setup_unix.sh`).*

---

### 🐧 Linux (Ubuntu / Debian / Distro Lain)
Buka **Terminal** (`Ctrl + Alt + T`), masuk ke folder proyek, dan jalankan:

```bash
bash setup_unix.sh
```

---

## Metode 2: Setup Manual Lewat Terminal

Bagi yang ingin menjalankan perintah instalasi baris demi baris secara langsung di terminal:

### 1. Perintah Terminal Windows (PowerShell)
Buka PowerShell di dalam folder proyek, lalu salin dan jalankan blok perintah berikut:

```powershell
python -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\python -m pip install opencv-python numpy
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
.\.venv\Scripts\python tes_kesiapan.py
```

### 2. Perintah Terminal macOS & Linux (Bash / Zsh)
Buka Terminal di dalam folder proyek, lalu salin dan jalankan blok perintah berikut:

```bash
python3 -m venv .venv
./.venv/bin/python -m pip install --upgrade pip
./.venv/bin/python -m pip install opencv-python numpy
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
./.venv/bin/python tes_kesiapan.py
```

---

## Verifikasi Kesiapan Sistem & Kamera

Untuk menguji kembali apakah environment dan webcam berfungsi tanpa mengulang proses instalasi dari awal, jalankan perintah ini kapan saja:

- **Windows:**
  ```powershell
  .\.venv\Scripts\python tes_kesiapan.py
  ```
- **macOS / Linux:**
  ```bash
  ./.venv/bin/python tes_kesiapan.py
  ```

Hasil pengujian yang berhasil akan menampilkan output:
```text
=======================================================
ENVIRONMENT & HARDWARE VERIFICATION
=======================================================
OS        : Windows / Linux / Darwin ...
Python    : 3.12.x (...)
NumPy     : x.x.x [OK]
OpenCV    : x.x.x [OK]
CV Algor. : Color Masking & Contours [OK]
Camera    : Detected (640x480) [OK]
=======================================================
STATUS    : ALL CORE CHECKS PASSED
INFO      : Kamera laptop terdeteksi dan siap untuk pengujian video.
Silakan simpan tangkapan layar ini sebagai konfirmasi kesiapan.
```

📸 **Jangan lupa simpan tangkapan layar (screenshot) tampilan di atas sebagai bukti kesiapan laptop Anda.**

---

## Panduan Penanganan Masalah (Troubleshooting)

Jika mengalami kendala, **kirimkan screenshot pesan galat ke grup WhatsApp peserta** agar dapat dibantu lebih cepat. Berikut beberapa solusi cepat untuk masalah umum:

| Masalah | Penyebab | Solusi |
| :--- | :--- | :--- |
| **`[PERINGATAN] FILE BERJALAN DARI DALAM FILE ZIP!`** | File `.bat` diklik langsung dari file arsip tanpa diekstrak. | Tutup jendela, klik kanan file zip $\rightarrow$ pilih **Extract All...** (Ekstrak Semua). Jalankan `setup_windows.bat` dari dalam folder hasil ekstrak. |
| **Pop-up biru: `Windows protected your PC`** | Fitur keamanan Windows SmartScreen pada skrip unduhan. | Klik **More info**, kemudian klik **Run anyway**. |
| **`Camera: Not detected / disabled by privacy switch`** | Shutter fisik webcam tertutup atau izin kamera Windows dinonaktifkan. | Buka penutup kamera fisik laptop atau buka **Settings > Privacy & Security > Camera** di Windows dan aktifkan izin akses kamera. *(Status ini bersifat opsional, materi tetap dapat berjalan dengan file video bawaan).* |
| **`'python' is not recognized as an internal or external command`** | Python belum masuk ke daftar Environment Variables (PATH). | Buka installer Python, pilih **Modify** $\rightarrow$ klik **Next** $\rightarrow$ centang **Add Python to environment variables** $\rightarrow$ klik **Install**. |
| **`ExecutionPolicy` / `running scripts is disabled` (PowerShell)** | Kebijakan restriksi script default Windows. | Anda tidak perlu mengaktifkan virtual environment (`activate`). Skrip dan perintah di atas menggunakan pemanggilan langsung `.\.venv\Scripts\python.exe`. |
| **`error: externally-managed-environment` (macOS/Linux)** | Sistem operasi membatasi instalasi pip langsung ke Python global sistem. | Selalu gunakan virtual environment (`.venv`) sesuai instruksi di atas. |
| **`ImportError: libGL.so.1` (Linux)** | Dependensi rendering grafis sistem belum terpasang. | Jalankan perintah terminal: `sudo apt update && sudo apt install -y libgl1 libglib2.0-0`. |
| **`No module named 'cv2'` pada file Notebook (`.ipynb`)** | VS Code memilih interpreter Python sistem, bukan `.venv`. | Buka file `.ipynb`, lihat pojok kanan atas editor $\rightarrow$ klik **Select Kernel** $\rightarrow$ pilih **Python Environments...** $\rightarrow$ pilih **.venv**. |
| **Koneksi gagal saat download library (`ReadTimeoutError`)** | Jaringan internet lambat atau terputus saat instalasi pip. | Pastikan laptop terhubung ke internet stabil, lalu jalankan ulang file setup. |

---

## Rencana Cadangan Hari H

Apabila laptop peserta mengalami kendala teknis spesifik yang belum terselesaikan hingga sesi registrasi selesai:
1. Peserta melapor ke meja panitia/asisten pada rentang waktu **07.00 – 07.30 WIB**.
2. Jika kendala sistem membutuhkan waktu lebih dari 15 menit perbaikan, peserta akan diarahkan menggunakan metode **Pair Programming** (bergabung dengan rekan satu meja yang environment-nya sudah terverifikasi `ALL CORE CHECKS PASSED`) agar waktu materi utama tidak tertunda.
