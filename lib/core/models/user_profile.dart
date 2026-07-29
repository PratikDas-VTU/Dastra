import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'user_profile_models.dart';

@immutable
class UserProfile {
  final int schemaVersion;
  final String? name;
  final ThemePreferences theme;
  final NotificationPreferences notifications;
  final OutputPreferences output;
  final GeneralPreferences general;
  final LocalizationPreferences localization;
  final List<String> favoriteToolIds;

  const UserProfile({
    this.schemaVersion = 1,
    this.name,
    this.theme = const ThemePreferences(),
    this.notifications = const NotificationPreferences(),
    this.output = const OutputPreferences(),
    this.general = const GeneralPreferences(),
    this.localization = const LocalizationPreferences(),
    this.favoriteToolIds = const [],
  });

  UserProfile copyWith({
    int? schemaVersion,
    String? name,
    bool clearName = false,
    ThemePreferences? theme,
    NotificationPreferences? notifications,
    OutputPreferences? output,
    GeneralPreferences? general,
    LocalizationPreferences? localization,
    List<String>? favoriteToolIds,
  }) {
    return UserProfile(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      name: clearName ? null : (name ?? this.name),
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      output: output ?? this.output,
      general: general ?? this.general,
      localization: localization ?? this.localization,
      favoriteToolIds: favoriteToolIds ?? this.favoriteToolIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'name': name,
      'theme': theme.toMap(),
      'notifications': notifications.toMap(),
      'output': output.toMap(),
      'general': general.toMap(),
      'localization': localization.toMap(),
      'favoriteToolIds': favoriteToolIds,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Handle legacy flat structure backward compatibility
    final int schemaVersion = map['schemaVersion'] as int? ?? 0;
    
    if (schemaVersion == 0) {
      // Migrate from flat format
      return UserProfile(
        schemaVersion: 1,
        name: map['name'] as String?,
        theme: ThemePreferences(
          mode: map['themeMode'] as String? ?? 'dark',
          accentColor: map['accentColor'] as String?,
        ),
        notifications: NotificationPreferences(
          enabled: map['notificationsEnabled'] as bool? ?? true,
          onSuccess: map['notifyOnSuccess'] as bool? ?? true,
          onError: map['notifyOnError'] as bool? ?? true,
          onCompletion: map['notifyOnCompletion'] as bool? ?? true,
        ),
        output: OutputPreferences(
          defaultFolder: map['defaultOutputFolder'] as String? ?? 'Original Location',
          rememberLastFolder: map['rememberLastFolder'] as bool? ?? true,
          openFileAfterConversion: map['openFileAfterConversion'] as bool? ?? true,
          openFolderAfterConversion: map['openFolderAfterConversion'] as bool? ?? false,
        ),
        general: GeneralPreferences(
          startupOption: map['startupOption'] as String? ?? 'home',
        ),
        localization: LocalizationPreferences(
          language: map['language'] as String? ?? 'en_US',
        ),
        favoriteToolIds: (map['favoriteToolIds'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    }

    return UserProfile(
      schemaVersion: schemaVersion,
      name: map['name'] as String?,
      theme: ThemePreferences.fromMap(map['theme'] as Map<String, dynamic>?),
      notifications: NotificationPreferences.fromMap(map['notifications'] as Map<String, dynamic>?),
      output: OutputPreferences.fromMap(map['output'] as Map<String, dynamic>?),
      general: GeneralPreferences.fromMap(map['general'] as Map<String, dynamic>?),
      localization: LocalizationPreferences.fromMap(map['localization'] as Map<String, dynamic>?),
      favoriteToolIds: (map['favoriteToolIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) {
    try {
      return UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
    } catch (_) {
      return const UserProfile();
    }
  }
}
