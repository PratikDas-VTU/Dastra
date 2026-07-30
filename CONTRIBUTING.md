# Contributing to Dastra

Thank you for your interest in contributing to Dastra! Dastra is an offline-first productivity and document engineering suite built with Flutter.

## How to Contribute
We welcome all forms of contributions, including:
- Bug reports and issue tracking
- Feature requests
- Documentation improvements

## Architecture Overview
Dastra v1.0.0 utilizes a **Dual-Edition Architecture**:
- **Community Edition**: The public, locked-down stable release.
- **Developer Edition**: An internal development environment that bypasses capability locks and uses an isolated `%LOCALAPPDATA%\DastraDeveloper` directory.

## Development Setup
1. Ensure you have the Flutter SDK (>=3.3.0) installed.
2. Clone the repository and run `flutter pub get`.
3. To test the developer version natively, run:
   ```bash
   flutter run -d windows --dart-define=EDITION=Developer --dart-define=BUILD_PROFILE=Developer --dart-define=RELEASE_CHANNEL=Development --dart-define=LICENSE_TIER="Internal Developer"
   ```
4. To build the installers, you must have Inno Setup 6 installed, then execute:
   ```powershell
   .\scripts\build_release_editions.ps1
   ```

## Code Standards
- Ensure `flutter analyze` passes perfectly.
- Avoid introducing any cloud dependencies. Dastra is fundamentally offline.
- Do not bypass the `FeatureGateService` for premium tools unless it is via the `BuildConfig.isDeveloperEdition` flag.

We look forward to your contributions in the v1.1.0 cycle!
