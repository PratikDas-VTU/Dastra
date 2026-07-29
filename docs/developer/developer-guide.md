# Dastra Developer Guide

Welcome to the Dastra codebase! This guide will help you get your local development environment set up and explain the core concepts of the project.

## Prerequisites

1. **Flutter SDK**: Ensure you have Flutter 3.x installed.
2. **Dart SDK**: Bundled with Flutter.
3. **IDE**: VS Code with the Flutter extension is highly recommended.
4. **Python**: Required only if you intend to rebuild the Windows Desktop backend engines (using PyInstaller).
5. **Visual Studio**: Required with C++ desktop development workload for Windows compilation.

## Getting Started

```bash
git clone https://github.com/yourusername/dastra.git
cd dastra
flutter pub get
flutter run -d windows
```

## Core Principles

1. **Offline First**: Never introduce network requests unless absolutely necessary (and even then, require explicit user opt-in).
2. **Null Safety**: Dastra uses strict null safety. Avoid using the `!` operator unless you are 100% certain the value is non-null. Use safe fallbacks.
3. **Immutability**: Prefer `const` widgets and immutable state models (`final` properties).

## Submitting Pull Requests

Please read the `CONTRIBUTING.md` file in the root directory for our PR and code review process.
