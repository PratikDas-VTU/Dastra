# Contributing to Dastra

Thank you for your interest in contributing to Dastra! Dastra is an offline-first productivity and document engineering suite built with Flutter.

## How to Contribute
Since Dastra is currently in its RC1 freeze, we are primarily looking for:
- Bug reports and issue tracking
- Feature requests
- Documentation improvements

At this stage, large architectural pull requests may not be accepted without prior discussion.

## Development Setup
1. Ensure you have the Flutter SDK (>=3.3.0) installed.
2. Clone the repository and run `flutter pub get`.
3. To test the developer version, run `flutter run -d windows --dart-define=BUILD_PROFILE=developer`.
4. Please follow the `docs/developer/` guidelines for adding new tools to the Tool Registry.

## Code Standards
- Ensure `flutter analyze` passes perfectly.
- Avoid introducing any cloud dependencies. Dastra is fundamentally offline.
- Do not bypass the `FeatureGateService` for premium tools.

We look forward to your contributions in the upcoming v1.1.0 cycle!
