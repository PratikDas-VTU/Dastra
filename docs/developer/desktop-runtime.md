# Desktop Runtime (Windows, macOS, Linux)

Dastra's desktop builds have the advantage of accessing the local file system seamlessly and executing bundled binaries.

## Python Integration (Windows)

Many document conversion tools (like PDF to Word) rely on bundled Python executables compiled via PyInstaller.

1. **Location**: `assets/engines/`
2. **Execution**: Dastra extracts the engine to a temporary directory using `path_provider` and executes it via `Process.run`.
3. **Communication**: JSON payloads over `stdout`/`stderr`.

## COM Automation (Windows Only)

For tools like Word to PDF, Dastra interacts directly with Microsoft Office (if installed) using the Windows Component Object Model (COM) via the `win32` Dart package. This provides 100% fidelity compared to reverse-engineered pure Dart libraries.

## Portable Execution

Dastra can run entirely as a Portable application on Windows. 
When Dastra detects it is running in portable mode, it writes all `dastra_workspace.db` data and temporary engine files into a local `data/` directory adjacent to the executable, rather than `AppData/Roaming`.
