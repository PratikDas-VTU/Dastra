import 'package:flutter/foundation.dart';

@immutable
class ThemePreferences {
  final String mode; // 'dark', 'light', 'system'
  final String? accentColor;

  const ThemePreferences({
    this.mode = 'dark',
    this.accentColor,
  });

  ThemePreferences copyWith({
    String? mode,
    String? accentColor,
    bool clearAccentColor = false,
  }) {
    return ThemePreferences(
      mode: mode ?? this.mode,
      accentColor: clearAccentColor ? null : (accentColor ?? this.accentColor),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'accentColor': accentColor,
    };
  }

  factory ThemePreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const ThemePreferences();
    return ThemePreferences(
      mode: map['mode'] as String? ?? 'dark',
      accentColor: map['accentColor'] as String?,
    );
  }
}

@immutable
class NotificationPreferences {
  final bool enabled;
  final bool onSuccess;
  final bool onError;
  final bool onCompletion;

  const NotificationPreferences({
    this.enabled = true,
    this.onSuccess = true,
    this.onError = true,
    this.onCompletion = true,
  });

  NotificationPreferences copyWith({
    bool? enabled,
    bool? onSuccess,
    bool? onError,
    bool? onCompletion,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      onSuccess: onSuccess ?? this.onSuccess,
      onError: onError ?? this.onError,
      onCompletion: onCompletion ?? this.onCompletion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'onSuccess': onSuccess,
      'onError': onError,
      'onCompletion': onCompletion,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPreferences();
    return NotificationPreferences(
      enabled: map['enabled'] as bool? ?? true,
      onSuccess: map['onSuccess'] as bool? ?? true,
      onError: map['onError'] as bool? ?? true,
      onCompletion: map['onCompletion'] as bool? ?? true,
    );
  }
}

@immutable
class OutputPreferences {
  final String defaultFolder;
  final bool rememberLastFolder;
  final bool openFileAfterConversion;
  final bool openFolderAfterConversion;

  const OutputPreferences({
    this.defaultFolder = 'Original Location',
    this.rememberLastFolder = true,
    this.openFileAfterConversion = true,
    this.openFolderAfterConversion = false,
  });

  OutputPreferences copyWith({
    String? defaultFolder,
    bool? rememberLastFolder,
    bool? openFileAfterConversion,
    bool? openFolderAfterConversion,
  }) {
    return OutputPreferences(
      defaultFolder: defaultFolder ?? this.defaultFolder,
      rememberLastFolder: rememberLastFolder ?? this.rememberLastFolder,
      openFileAfterConversion: openFileAfterConversion ?? this.openFileAfterConversion,
      openFolderAfterConversion: openFolderAfterConversion ?? this.openFolderAfterConversion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultFolder': defaultFolder,
      'rememberLastFolder': rememberLastFolder,
      'openFileAfterConversion': openFileAfterConversion,
      'openFolderAfterConversion': openFolderAfterConversion,
    };
  }

  factory OutputPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const OutputPreferences();
    return OutputPreferences(
      defaultFolder: map['defaultFolder'] as String? ?? 'Original Location',
      rememberLastFolder: map['rememberLastFolder'] as bool? ?? true,
      openFileAfterConversion: map['openFileAfterConversion'] as bool? ?? true,
      openFolderAfterConversion: map['openFolderAfterConversion'] as bool? ?? false,
    );
  }
}

@immutable
class GeneralPreferences {
  final String startupOption; // 'home', 'workspace', 'resume_last'

  const GeneralPreferences({
    this.startupOption = 'home',
  });

  GeneralPreferences copyWith({
    String? startupOption,
  }) {
    return GeneralPreferences(
      startupOption: startupOption ?? this.startupOption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupOption': startupOption,
    };
  }

  factory GeneralPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GeneralPreferences();
    return GeneralPreferences(
      startupOption: map['startupOption'] as String? ?? 'home',
    );
  }
}

@immutable
class LocalizationPreferences {
  final String language;

  const LocalizationPreferences({
    this.language = 'en_US',
  });

  LocalizationPreferences copyWith({
    String? language,
  }) {
    return LocalizationPreferences(
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
    };
  }

  factory LocalizationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const LocalizationPreferences();
    return LocalizationPreferences(
      language: map['language'] as String? ?? 'en_US',
    );
  }
}
