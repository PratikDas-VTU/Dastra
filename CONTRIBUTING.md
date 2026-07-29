# Contributing to Dastra

Thank you for your interest in contributing to Dastra! Dastra is a privacy-first, offline productivity suite. We welcome contributions of all kinds: bug reports, feature requests, documentation improvements, and code contributions.

## How to Contribute

### 1. Reporting Bugs
- Check the issue tracker to ensure the bug hasn't already been reported.
- Open a new issue using the Bug Report template.
- Include your operating system, Dastra version, and steps to reproduce.

### 2. Suggesting Features
- Open an issue using the Feature Request template.
- Clearly describe the use case and why it benefits Dastra's offline-first philosophy.

### 3. Code Contributions
- Fork the repository.
- Create a feature branch (`git checkout -b feature/your-feature-name`).
- Commit your changes with descriptive messages (`git commit -m 'Add new PDF compression engine'`).
- Push to your branch (`git push origin feature/your-feature-name`).
- Open a Pull Request.

## Coding Guidelines
- **Architecture**: Dastra uses a `Screen -> Controller -> Service -> Storage` architecture. Ensure your changes respect these boundaries.
- **State Management**: We use `Provider`. Do not introduce new state management libraries.
- **Styling**: Always use the `BuildContext` extensions for theming (e.g., `context.colors`, `context.typography`). Avoid hardcoded colors.
- **Privacy**: Dastra is offline-first. Never introduce features that send data over the network without explicit, opt-in user consent.

## Running Tests
Before opening a pull request, ensure your code passes all checks:
```bash
flutter analyze
flutter test
```
