# Dastra Windows Installer Build Guide

This document outlines the process for building and packaging the Dastra Windows installer (`DastraSetup.exe`) and portable distributions.

## Prerequisites

To build the installer locally, you will need:
1.  **Flutter SDK** (Channel: Stable)
2.  **Visual Studio 2022** (with "Desktop development with C++" workload)
3.  **Inno Setup 6+** (can be installed via `choco install innosetup` or downloaded from [jrsoftware.org](https://jrsoftware.org/isinfo.php))

## Build Architecture

The installer is powered by Inno Setup and is defined in `scripts/windows_setup.iss`. The script is designed to handle:
*   **Dual Mode Installation:** Installs per-user (`%LOCALAPPDATA%\Programs\Dastra`) by default without requiring UAC prompts. If launched with Administrator privileges, it installs machine-wide to `%ProgramFiles%\Dastra`.
*   **Asset Bundling:** It recursively bundles the entire `build\windows\x64\runner\Release` output directory, meaning Visual C++ runtime DLLs (`msvcp140.dll`, etc.) and all Flutter plugin DLLs are naturally packaged alongside `dastra.exe`.
*   **Update Support:** The installer uses a static `AppId` (`{{9A2A622B-DFF2-4E89-9317-B9026AD9EDA9}`), meaning executing a newer version of the installer will automatically detect and upgrade the existing installation seamlessly.

## Step-by-Step Local Build

1.  **Bump the Version:** Update the version number in `pubspec.yaml` (e.g., `version: 1.1.0+2`). The CI pipeline automatically syncs this, but for local builds, ensure it matches your intentions.
2.  **Execute the Release Pipeline:**
    We provide a fully automated PowerShell script that builds both the **Community Edition** and **Developer Edition** in sequence.
    ```powershell
    .\scripts\build_release_editions.ps1
    ```
    
    This script will:
    * Compile the Developer Edition binaries with `EDITION=Developer` flags.
    * Compile `DastraDeveloperSetup.exe` utilizing an isolated `%LOCALAPPDATA%\DastraDeveloper` directory.
    * Compile the Community Edition binaries with `EDITION=Community` flags.
    * Compile `DastraSetup.exe` utilizing the standard `%LOCALAPPDATA%\Dastra` directory.
    * Export everything into `Dastra_Release_Artifacts\`.

## Continuous Integration (GitHub Actions)

Releases are fully automated via GitHub Actions (`.github/workflows/release.yml`).
The release pipeline triggers automatically when a semantic version tag (e.g., `v1.0.0`) is pushed to the repository.

The pipeline performs the following actions:
1.  Builds the Windows Release binary.
2.  Compiles the `DastraSetup.exe` installer using Inno Setup.
3.  Zips the release folder to create `DastraPortable.zip`.
4.  Builds the Android APK.
5.  Generates `SHA256SUMS.txt` for all artifacts.
6.  Creates a GitHub Release containing all these artifacts.

To trigger a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## Required Assets
The setup script relies on the following assets being present in the repository:
*   `windows\runner\resources\app_icon.ico`: The primary application and installer icon.
*   `LICENSE`: The text license bundled with the installer.

## Future Recommendations
*   **Code Signing:** Currently, the installer is not signed, which will trigger Microsoft SmartScreen warnings. Future enterprise releases should integrate `SignTool` into the Inno Setup script (`SignTool=...`) with an EV Code Signing certificate.
