import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/storage/storage_service.dart';
import '../../../settings/services/user_preferences_service.dart';
import '../model/output_configuration.dart';

class OutputService {
  final StorageService _storage;
  final UserPreferencesService _preferencesService;

  OutputService(this._storage, this._preferencesService);

  static const _lastFolderKey = 'dastra_last_output_folder';

  Future<String> getDefaultOutputFolder() async {
    final prefs = _preferencesService.profile.output;
    
    // 1. Try to use default folder if explicitly set (and not Original Location)
    if (prefs.defaultFolder != 'Original Location' && await Directory(prefs.defaultFolder).exists()) {
      return prefs.defaultFolder;
    }

    // 2. Try last folder if remember is enabled
    if (prefs.rememberLastFolder) {
      final lastFolder = _storage.getString(_lastFolderKey);
      if (lastFolder != null && await Directory(lastFolder).exists()) {
        return lastFolder;
      }
    }
    
    // 3. Fallback to exports
    return await _storage.getExportsDirectory();
  }

  Future<String?> pickFolder(String initialDirectory) async {
    final result = await FilePicker.getDirectoryPath(
      initialDirectory: initialDirectory,
      dialogTitle: 'Select Output Folder',
    );
    return result;
  }

  Future<String> resolveUniquePath(String requestedPath, DuplicateHandlingStrategy strategy) async {
    if (strategy == DuplicateHandlingStrategy.replace) {
      return requestedPath;
    }

    final file = File(requestedPath);
    if (!await file.exists()) return requestedPath;

    final dir = file.parent.path;
    final ext = p.extension(requestedPath);
    final base = p.basenameWithoutExtension(requestedPath);

    int counter = 1;
    String newPath;
    do {
      newPath = p.join(dir, '$base ($counter)$ext');
      counter++;
    } while (await File(newPath).exists());

    return newPath;
  }

  Future<File> saveFile(String requestedPath, Uint8List bytes, OutputConfiguration config) async {
    if (config.rememberFolder) {
      await _storage.setString(_lastFolderKey, config.folderPath);
    }
    
    final strategy = config.duplicateStrategy == DuplicateHandlingStrategy.ask 
      ? DuplicateHandlingStrategy.autoRename 
      : config.duplicateStrategy;

    final finalPath = await resolveUniquePath(requestedPath, strategy);
    final file = File(finalPath);
    
    // Ensure parent dir exists
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<File> moveFile(String sourcePath, String requestedPath, OutputConfiguration config) async {
    if (config.rememberFolder) {
      await _storage.setString(_lastFolderKey, config.folderPath);
    }

    final strategy = config.duplicateStrategy == DuplicateHandlingStrategy.ask 
      ? DuplicateHandlingStrategy.autoRename 
      : config.duplicateStrategy;

    final finalPath = await resolveUniquePath(requestedPath, strategy);
    final source = File(sourcePath);
    final file = File(finalPath);
    
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    
    try {
      return await source.rename(finalPath);
    } catch (_) {
      final newFile = await source.copy(finalPath);
      await source.delete();
      return newFile;
    }
  }
}
