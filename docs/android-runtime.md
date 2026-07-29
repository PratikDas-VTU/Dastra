# Android Runtime

Dastra on Android operates within the constraints of the mobile OS sandbox.

## Storage Scoped Access

Unlike Desktop, Dastra cannot arbitrarily read/write to `C:\`. Android requires Scoped Storage.
- Dastra uses `file_picker` to obtain temporary URI access to files.
- Processed outputs are saved to the application's internal documents directory or exposed via the standard Android Share sheet.

## Native Dependencies

Android does not support bundled Python executables. Therefore, tools that rely on `assets/engines/pdf2docx.exe` are gracefully disabled on Android, or fall back to Pure Dart implementations.

If native C/C++ processing is required, it must be compiled via NDK and accessed via FFI (`dart:ffi`).

## Background Processing

Long-running tasks (like bulk image compression) should ideally be offloaded to an Android Foreground Service if they exceed a few seconds, though this is currently handled by Dart `Isolates` to prevent UI freezing.
