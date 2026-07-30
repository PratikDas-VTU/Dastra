import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'storage_strategy.dart';
import '../config/build_config.dart';

class StandardStorageStrategy implements StorageStrategy {
  late final String _appDataRoot;

  @override
  Future<void> initialize() async {
    String basePath;
    if (Platform.isWindows) {
      basePath = Platform.environment['LOCALAPPDATA'] ?? (await getApplicationSupportDirectory()).path;
    } else {
      basePath = (await getApplicationSupportDirectory()).path;
    }

    final String folderName = BuildConfig.isDeveloperEdition ? 'DastraDeveloper' : 'Dastra';
    _appDataRoot = p.join(basePath, folderName);

    await _ensureDirectoryExists(await getDatabaseDirectory());
    await _ensureDirectoryExists(await getSettingsDirectory());
    await _ensureDirectoryExists(await getTempDirectory());
    // Downloads dir can just be the OS downloads dir.
  }

  Future<void> _ensureDirectoryExists(Directory dir) async {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<Directory> getDatabaseDirectory() async => Directory(p.join(_appDataRoot, 'Database'));

  @override
  Future<Directory> getSettingsDirectory() async => Directory(p.join(_appDataRoot, 'Settings'));

  @override
  Future<Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final dastraTemp = Directory(p.join(tempDir.path, 'Dastra'));
    await _ensureDirectoryExists(dastraTemp);
    return dastraTemp;
  }

  @override
  Future<Directory> getExportsDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return downloads;
    }
    // Fallback if Downloads is not available (e.g., some Android configs)
    return Directory(p.join(_appDataRoot, 'Exports'));
  }

  @override
  Future<Directory> getLogsDirectory() async => Directory(p.join(_appDataRoot, 'Logs'));
}
