# Settings Architecture

The Settings module handles global application preferences, licensing, about information, and telemetry opt-outs (though Dastra currently has zero telemetry).

## State Management

Settings state is managed exclusively by the `UserPreferencesController`.

```dart
class UserPreferencesController extends ChangeNotifier {
  // Reads and writes from SharedPreferences
}
```

## Theming Controls
Users can switch between:
- Light Mode
- Dark Mode
- System Default

This setting is stored locally and applied at the root of the app in `main.dart` via the `MaterialApp(themeMode: ...)` property.

## About Screen
The About screen dynamically reads the application version and build number from the binary metadata using `package_info_plus`. It does not use hardcoded strings, ensuring the UI always reflects the actual deployed binary.
