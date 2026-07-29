import 'dart:io';
import 'package:path/path.dart' as p;
import 'storage_strategy.dart';

class PortableStorageStrategy implements StorageStrategy {
  late final String _dataRoot;

  @override
  Future<void> initialize() async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    _dataRoot = p.join(exeDir, 'data');

    await _ensureDirectoryExists(await getDatabaseDirectory());
    await _ensureDirectoryExists(await getSettingsDirectory());
    await _ensureDirectoryExists(await getTempDirectory());
    await _ensureDirectoryExists(await getExportsDirectory());
    await _ensureDirectoryExists(await getLogsDirectory());
  }

  Future<void> _ensureDirectoryExists(Directory dir) async {
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  @override
  Future<Directory> getDatabaseDirectory() async => Directory(p.join(_dataRoot, 'database'));

  @override
  Future<Directory> getSettingsDirectory() async => Directory(p.join(_dataRoot, 'settings'));

  @override
  Future<Directory> getTempDirectory() async => Directory(p.join(_dataRoot, 'temp'));

  @override
  Future<Directory> getExportsDirectory() async => Directory(p.join(_dataRoot, 'exports'));

  @override
  Future<Directory> getLogsDirectory() async => Directory(p.join(_dataRoot, 'logs'));
}
