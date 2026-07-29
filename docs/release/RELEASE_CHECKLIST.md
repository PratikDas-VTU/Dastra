# Release Checklist

This checklist is mandatory before tagging and building any new official release of Dastra. Ensure all items are verified to maintain production-quality software.

## Pre-Flight Verification
- [ ] `flutter analyze` passes with 0 errors.
- [ ] `flutter test` passes successfully.

## Platform Builds
- [ ] Windows Build completes successfully (`flutter build windows`).
- [ ] Android Build completes successfully (`flutter build apk` and `flutter build appbundle`).

## QA & Review
- [ ] Documentation review: All Markdown files in `/docs` and the `README.md` are up to date with new features.
- [ ] Screenshot review: Screenshots in `assets/screenshots/` reflect the current UI.
- [ ] Version verification: `pubspec.yaml`, `VERSION`, and `AboutScreen` all reflect the new version number.
- [ ] Changelog verification: `CHANGELOG.md` is updated with all notable changes and the release date.
- [ ] **License verification**: *[PENDING]* Ensure the correct `LICENSE` file is generated and included.

## Feature Validation
- [ ] Runtime verification: Verify Python/Com bindings for Windows operate correctly in the portable build.
- [ ] Tool verification: Ensure each tool category (Document, Image, Security) successfully executes a task end-to-end.
- [ ] Theme verification: Verify Light Mode, Dark Mode, and Dynamic Colors render correctly without unreadable contrast.
- [ ] Responsive verification: Verify the application layout adapts correctly across Desktop, Tablet, and Mobile form factors.
