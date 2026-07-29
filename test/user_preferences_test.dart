import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/core/models/models.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('default constructor sets proper defaults', () {
      const profile = UserProfile();
      expect(profile.schemaVersion, 1);
      expect(profile.name, isNull);
      expect(profile.theme.mode, 'dark');
      expect(profile.general.startupOption, 'home');
      expect(profile.notifications.enabled, true);
      expect(profile.output.defaultFolder, 'Original Location');
      expect(profile.output.rememberLastFolder, true);
      expect(profile.output.openFileAfterConversion, true);
      expect(profile.output.openFolderAfterConversion, false);
      expect(profile.localization.language, 'en_US');
    });

    test('copyWith updates fields correctly', () {
      const profile = UserProfile();
      final updated = profile.copyWith(
        name: 'Pratik',
        theme: profile.theme.copyWith(mode: 'light'),
        general: profile.general.copyWith(startupOption: 'workspace'),
        notifications: profile.notifications.copyWith(enabled: false),
      );

      expect(updated.name, 'Pratik');
      expect(updated.theme.mode, 'light');
      expect(updated.general.startupOption, 'workspace');
      expect(updated.notifications.enabled, false);
      expect(updated.output.defaultFolder, 'Original Location');
    });

    test('copyWith clearName sets name to null', () {
      const profile = UserProfile(name: 'Pratik');
      final cleared = profile.copyWith(clearName: true);
      expect(cleared.name, isNull);
    });

    test('toJson and fromJson serialize and deserialize correctly', () {
      final original = UserProfile(
        name: 'Alex',
        theme: const ThemePreferences(mode: 'system'),
        general: const GeneralPreferences(startupOption: 'resume_last'),
        notifications: const NotificationPreferences(enabled: false),
        output: const OutputPreferences(
          defaultFolder: 'C:\\Users\\Alex\\Documents',
          rememberLastFolder: false,
          openFileAfterConversion: false,
          openFolderAfterConversion: true,
        ),
        localization: const LocalizationPreferences(language: 'en_US'),
      );

      final jsonString = original.toJson();
      final deserialized = UserProfile.fromJson(jsonString);

      expect(deserialized.name, 'Alex');
      expect(deserialized.theme.mode, 'system');
      expect(deserialized.general.startupOption, 'resume_last');
      expect(deserialized.notifications.enabled, false);
      expect(deserialized.output.defaultFolder, 'C:\\Users\\Alex\\Documents');
      expect(deserialized.output.rememberLastFolder, false);
      expect(deserialized.output.openFileAfterConversion, false);
      expect(deserialized.output.openFolderAfterConversion, true);
    });

    test('fromJson handles legacy flat structure migration correctly', () {
      const legacyJson = '{"name":"LegacyUser","themeMode":"light","startupOption":"resume_last","notificationsEnabled":false,"defaultOutputFolder":"D:\\\\Export","rememberLastFolder":false,"openFileAfterConversion":false,"openFolderAfterConversion":true,"language":"fr_FR"}';
      
      final migrated = UserProfile.fromJson(legacyJson);
      
      expect(migrated.schemaVersion, 1);
      expect(migrated.name, 'LegacyUser');
      expect(migrated.theme.mode, 'light');
      expect(migrated.general.startupOption, 'resume_last');
      expect(migrated.notifications.enabled, false);
      expect(migrated.output.defaultFolder, 'D:\\Export');
      expect(migrated.output.rememberLastFolder, false);
      expect(migrated.output.openFileAfterConversion, false);
      expect(migrated.output.openFolderAfterConversion, true);
      expect(migrated.localization.language, 'fr_FR');
    });
  });
}
