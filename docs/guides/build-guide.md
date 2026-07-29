# Build Guide

This guide explains how to compile Dastra from source.

## Standard Build

To build the application for your current host platform:

```bash
# Get dependencies
flutter pub get

# Build Windows Executable
flutter build windows

# Build Android APK
flutter build apk

# Build Android AppBundle (for Play Store)
flutter build appbundle
```

## Building Native Engines

Dastra's desktop variant relies on bundled Python executables for certain heavy-lifting tasks (like PDF conversion).

If you modify the Python scripts in `assets/engines/src/`, you must recompile them using PyInstaller:

```bash
cd assets/engines/src/pdf2docx
pip install -r requirements.txt
pyinstaller --onefile --noconsole main.py
copy dist\main.exe ..\..\pdf2docx\pdf2docx.exe
```

*Note: You must compile the engines on the target OS (e.g., compile on Windows for the Windows `.exe`).*
