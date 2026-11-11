import platform
import sys

EXPECTED_VERSIONS = {
    "numpy": "2.2.6",
    "cv2": "4.12.0",
    "matplotlib": "3.10.3",
    "ipykernel": "6.29.5",
}


def _format_status(name, installed, expected):
    if installed == expected:
        return f"{installed} [OK]"
    return f"{installed} [OK - target {expected}]"


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
        print(f"NumPy     : {_format_status('numpy', np.__version__, EXPECTED_VERSIONS['numpy'])}")
    except Exception as exc:
        failed.append(f"NumPy: {exc}")
        print(f"NumPy     : FAILED ({exc})")

    # 2. Uji OpenCV
    cv2_module = None
    try:
        import cv2
        cv2_module = cv2
        print(f"OpenCV    : {_format_status('cv2', cv2.__version__, EXPECTED_VERSIONS['cv2'])}")
    except Exception as exc:
        failed.append(f"OpenCV: {exc}")
        print(f"OpenCV    : FAILED ({exc})")

    # 3. Uji Matplotlib
    plt_module = None
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
        plt_module = plt
        print(f"Matplotlib: {_format_status('matplotlib', matplotlib.__version__, EXPECTED_VERSIONS['matplotlib'])}")
    except Exception as exc:
        failed.append(f"Matplotlib: {exc}")
        print(f"Matplotlib: FAILED ({exc})")

    # 4. Uji IPyKernel (Kernel Notebook VS Code)
    try:
        import ipykernel
        print(f"IPyKernel : {_format_status('ipykernel', ipykernel.__version__, EXPECTED_VERSIONS['ipykernel'])}")
    except Exception as exc:
        failed.append(f"IPyKernel: {exc}")
        print(f"IPyKernel : FAILED ({exc})")

    # 5. Uji Pemrosesan Citra & Visualisasi
    if cv2_module and "numpy" in sys.modules:
        try:
            canvas = np.zeros((120, 120, 3), dtype=np.uint8)
            cv2.circle(canvas, (60, 60), 30, (0, 0, 255), -1)

            hsv = cv2.cvtColor(canvas, cv2.COLOR_BGR2HSV)
            mask = cv2.inRange(hsv, np.array([0, 50, 50]), np.array([10, 255, 255]))
            cnts, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            assert len(cnts) == 1

            if plt_module:
                fig = plt_module.figure(figsize=(2, 2))
                plt_module.imshow(cv2.cvtColor(canvas, cv2.COLOR_BGR2RGB))
                plt_module.close(fig)

            print("CV Algor. : Color Masking, Contours & Plot [OK]")
        except Exception as exc:
            failed.append(f"CV Algorithm: {exc}")
            print(f"CV Algor. : FAILED ({exc})")

    # 6. Uji Akses Kamera Laptop (Webcam)
    camera_detected = False
    if cv2_module:
        try:
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
                f"Pemeriksaan selesai.\nPython, OpenCV, NumPy, Matplotlib, dan IPyKernel berfungsi 100%.\n\n{cam_info}\nLaptop siap untuk workshop!"
            )
        else:
            err_msg = "\n".join(errors) if errors else "Terjadi kesalahan."
            messagebox.showerror("Status Kesiapan", f"Pemeriksaan gagal:\n{err_msg}")
        root.destroy()
    except Exception:
        pass


if __name__ == "__main__":
    run_check()
