import platform
import sys

def run_check():
    print("=" * 55)
    print("ENVIRONMENT & HARDWARE VERIFICATION")
    print("=" * 55)
    print(f"OS        : {platform.system()} {platform.release()} ({platform.machine()})")
    print(f"Python    : {sys.version.split()[0]} ({sys.executable})")

    failed = []

    # 1. Uji NumPy
    try:
        import numpy as np
        arr_test = np.zeros((10, 10, 3), dtype=np.uint8)
        assert arr_test.shape == (10, 10, 3)
        print(f"NumPy     : {np.__version__} [OK]")
    except Exception as exc:
        failed.append(f"NumPy: {exc}")
        print(f"NumPy     : FAILED ({exc})")

    # 2. Uji OpenCV
    cv2_module = None
    try:
        import cv2
        cv2_module = cv2
        print(f"OpenCV    : {cv2.__version__} [OK]")
    except Exception as exc:
        failed.append(f"OpenCV: {exc}")
        print(f"OpenCV    : FAILED ({exc})")

    # 3. Uji Pemrosesan Citra (Algoritma Color Object Counter)
    if cv2_module and "numpy" in sys.modules:
        try:
            # Buat kanvas citra sintetis
            canvas = np.zeros((120, 120, 3), dtype=np.uint8)
            cv2.circle(canvas, (60, 60), 30, (0, 0, 255), -1)  # Lingkaran merah
            
            # Konversi BGR -> HSV
            hsv = cv2.cvtColor(canvas, cv2.COLOR_BGR2HSV)
            
            # Masking warna merah
            mask = cv2.inRange(hsv, np.array([0, 50, 50]), np.array([10, 255, 255]))
            
            # Deteksi kontur objek
            cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            assert len(cnts) == 1
            print("CV Algor. : Color Masking & Contours [OK]")
        except Exception as exc:
            failed.append(f"CV Algorithm: {exc}")
            print(f"CV Algor. : FAILED ({exc})")

    # 4. Uji Akses Kamera Laptop (Webcam)
    camera_detected = False
    if cv2_module:
        try:
            # Inisialisasi video capture default (index 0)
            cap = cv2.VideoCapture(0)
            if cap.isOpened():
                ret, frame = cap.read()
                if ret and frame is not None:
                    camera_detected = True
                    h, w, _ = frame.shape
                    print(f"Camera    : Detected ({w}x{h}) [OK]")
                else:
                    print("Camera    : Device ready, but frame capture skipped [STANDBY]")
                cap.release()
            else:
                print("Camera    : Not detected / disabled by privacy switch [OPTIONAL]")
        except Exception as exc:
            print(f"Camera    : Warning ({exc}) [OPTIONAL]")

    print("=" * 55)

    if not failed:
        print("STATUS    : ALL CORE CHECKS PASSED")
        if camera_detected:
            print("INFO      : Kamera laptop terdeteksi dan siap untuk pengujian video.")
        else:
            print("INFO      : Kamera laptop tidak aktif (opsional, materi dapat memakai file video).")
        print("Silakan simpan tangkapan layar ini sebagai konfirmasi kesiapan.")
        _show_popup(True, camera_detected)
        sys.exit(0)
    else:
        print("STATUS    : VERIFICATION FAILED")
        for err in failed:
            print(f"- {err}")
        _show_popup(False, camera_detected, failed)
        sys.exit(1)

def _show_popup(success, camera_ok, errors=None):
    try:
        import tkinter as tk
        from tkinter import messagebox
        root = tk.Tk()
        root.withdraw()
        if success:
            cam_info = "Kamera laptop terdeteksi dan aktif." if camera_ok else "Kamera fisik tidak aktif (opsional)."
            messagebox.showinfo(
                "Status Kesiapan",
                f"Pemeriksaan selesai.\nPython, OpenCV, dan NumPy berfungsi 100%.\n\n{cam_info}\nLaptop siap untuk workshop!"
            )
        else:
            err_msg = "\n".join(errors) if errors else "Terjadi kesalahan."
            messagebox.showerror("Status Kesiapan", f"Pemeriksaan gagal:\n{err_msg}")
        root.destroy()
    except Exception:
        pass

if __name__ == "__main__":
    run_check()
