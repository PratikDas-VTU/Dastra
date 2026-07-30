import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

import 'storage_strategy.dart';
import 'portable_storage_strategy.dart';
import 'standard_storage_strategy.dart';

class StorageService {
  final StorageStrategy strategy;
  late Map<String, dynamic> _settings;
  late File _settingsFile;

  StorageService({required this.strategy});

  static Future<StorageService> initialize({bool usePortableMode = true}) async {
    final strategy = usePortableMode ? PortableStorageStrategy() : StandardStorageStrategy();
    await strategy.initialize();
    
    final service = StorageService(strategy: strategy);
    await service._initSettings();
    return service;
  }

  Future<void> _initSettings() async {
    final settingsDir = await strategy.getSettingsDirectory();
    _settingsFile = File(p.join(settingsDir.path, 'settings.json'));
    
    if (await _settingsFile.exists()) {
      try {
        final content = await _settingsFile.readAsString();
        _settings = jsonDecode(content) as Map<String, dynamic>;
      } catch (_) {
        _settings = {};
      }
    } else {
      _settings = {};
    }
  }

  Future<void> _saveSettings() async {
    await _settingsFile.writeAsString(jsonEncode(_settings));
  }

  // --- Paths ---

  Future<String> getDatabasePath(String dbName) async {
    final dir = await strategy.getDatabaseDirectory();
    return p.join(dir.path, dbName);
  }

  Future<String> getTempPath(String filename) async {
    final dir = await strategy.getTempDirectory();
    return p.join(dir.path, filename);
  }

  Future<String> getExportsDirectory() async {
    final dir = await strategy.getExportsDirectory();
    return dir.path;
  }

  /// Get the absolute path to a bundled engine asset.
  String getEngineAssetPath(String relativeAssetPath) {
    // Assets are typically bundled relative to the executable in flutter_assets on Desktop
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return p.join(exeDir, 'data', 'flutter_assets', 'assets', 'engines', relativeAssetPath);
  }

  // --- Settings (Replacing SharedPreferences) ---

  String? getString(String key) => _settings[key] as String?;
  int? getInt(String key) => _settings[key] as int?;
  bool? getBool(String key) => _settings[key] as bool?;

  Future<void> setString(String key, String value) async {
    _settings[key] = value;
    await _saveSettings();
  }

  Future<void> setInt(String key, int value) async {
    _settings[key] = value;
    await _saveSettings();
  }

  Future<void> setBool(String key, bool value) async {
    _settings[key] = value;
    await _saveSettings();
  }

  /// Developer only: Wipe all local data and recreate directory structure
  Future<void> resetLocalData() async {
    _settings.clear();
    
    final dirsToWipe = [
      await strategy.getDatabaseDirectory(),
      await strategy.getSettingsDirectory(),
      await strategy.getTempDirectory(),
      await strategy.getLogsDirectory(),
    ];

    for (final dir in dirsToWipe) {
      if (await dir.exists()) {
        try {
          await dir.delete(recursive: true);
        } catch (_) {
          // Ignore locks
        }
      }
    }

    // Recreate empty structure
    await strategy.initialize();

    // Terminate process to force a clean restart
    exit(0);
  }
}
