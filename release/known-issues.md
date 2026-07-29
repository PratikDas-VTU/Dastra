# Known Issues (v1.0 RC1)

Before submitting a bug report, please review the known issues for this release candidate:

## Windows
1. **Antivirus False Positives**: Because Dastra uses PyInstaller to bundle standalone Python conversion engines (e.g., for PDF to Word), Windows Defender or third-party AVs may falsely flag the executables. You may need to add an exclusion.
2. **Path Length Limits**: Extremely long file paths (over 260 characters) may cause the PDF processing tools to fail due to Win32 API limitations.

## Android
1. **Scoped Storage Quirks**: On Android 11+, selecting files from certain third-party file managers via the intent picker may return an invalid URI. Always use the system default file picker if possible.
2. **Missing Tools**: Tools requiring COM automation (like Word to PDF) are intentionally hidden on Android.

## General
1. **Memory Usage**: Processing massive PDFs (>500MB) can cause high memory usage spikes resulting in temporary UI stuttering. We are moving this entirely to isolated processes in v1.1.
