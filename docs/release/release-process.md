# Release Process

This document outlines the exact steps a maintainer must take to publish a new official version of Dastra.

## 1. Version Bump
1. Open `pubspec.yaml` and update the `version:` field (e.g., `1.1.0+2`).
2. Open the `VERSION` file in the root directory and update it.
3. Update `CHANGELOG.md` with the new version number, date, and notable changes.

## 2. Execute Pre-flight Checklist
Run through every item in `RELEASE_CHECKLIST.md` located in the root repository. Do not skip any steps.

## 3. Build Binaries
```bash
flutter build windows
flutter build apk
```

## 4. Package for Distribution
Use the packaging scripts (or manual zip process) to create:
- `Dastra-vX.Y.Z-Windows-Portable.zip`
- `Dastra-vX.Y.Z-Android.apk`

## 5. Tag and Release
1. Commit all changes: `git commit -am "chore: release v1.1.0"`
2. Tag the commit: `git tag v1.1.0`
3. Push to origin: `git push origin main --tags`
4. Create a new GitHub Release, upload the binaries, and copy the contents of `release/github-release.md` into the description.
