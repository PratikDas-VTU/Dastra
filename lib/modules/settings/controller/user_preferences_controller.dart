import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/storage/storage_service.dart';
import '../../../../core/models/models.dart';
import '../../workspace/domain/workspace_repository.dart';
import '../services/user_preferences_service.dart';

class UserPreferencesController extends ChangeNotifier {
  final UserPreferencesService _preferencesService;
  final StorageService _storage; // Kept for getExportsDirectory()
  final WorkspaceRepository _workspaceRepository;
  bool _isLoading = false;

  UserPreferencesController(
    this._preferencesService,
    this._storage,
    this._workspaceRepository,
  ) {
    _preferencesService.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _preferencesService.removeListener(notifyListeners);
    super.dispose();
  }

  UserProfile get profile => _preferencesService.profile;
  bool get isLoading => _isLoading;

  bool get hasSeenOnboarding => _preferencesService.hasSeenOnboarding;

  Future<void> _saveProfile(UserProfile newProfile) async {
    await _preferencesService.saveProfile(newProfile);
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    await _preferencesService.setHasSeenOnboarding(value);
  }

  bool isFavorite(String toolId) {
    return _preferencesService.isFavorite(toolId);
  }

  Future<void> toggleFavorite(String toolId) async {
    await _preferencesService.toggleFavorite(toolId);
  }

  Future<void> updateName(String? name) async {
    final trimmed = name?.trim();
    final newProfile = profile.copyWith(
      name: trimmed,
      clearName: trimmed == null || trimmed.isEmpty,
    );
    await _saveProfile(newProfile);
  }

  Future<void> updateThemeMode(String themeMode) async {
    await _saveProfile(profile.copyWith(theme: profile.theme.copyWith(mode: themeMode)));
  }

  Future<void> updateStartupOption(String startupOption) async {
    await _saveProfile(profile.copyWith(general: profile.general.copyWith(startupOption: startupOption)));
  }

  Future<void> updateDefaultOutputFolder(String path) async {
    await _saveProfile(profile.copyWith(output: profile.output.copyWith(defaultFolder: path)));
  }

  Future<String?> pickAndSetDefaultOutputFolder() async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select Default Save Location',
    );
    if (result != null) {
      await updateDefaultOutputFolder(result);
      return result;
    }
    return null;
  }

  Future<void> resetDefaultOutputFolder() async {
    await _saveProfile(profile.copyWith(output: profile.output.copyWith(defaultFolder: 'Original Location')));
  }

  Future<void> toggleRememberLastFolder(bool value) async {
    await _saveProfile(profile.copyWith(output: profile.output.copyWith(rememberLastFolder: value)));
  }

  Future<void> toggleOpenFileAfterConversion(bool value) async {
    await _saveProfile(profile.copyWith(output: profile.output.copyWith(openFileAfterConversion: value)));
  }

  Future<void> toggleOpenFolderAfterConversion(bool value) async {
    await _saveProfile(profile.copyWith(output: profile.output.copyWith(openFolderAfterConversion: value)));
  }

  Future<void> toggleNotifications(bool value) async {
    await _saveProfile(profile.copyWith(notifications: profile.notifications.copyWith(enabled: value)));
  }

  Future<void> toggleNotifyOnSuccess(bool value) async {
    await _saveProfile(profile.copyWith(notifications: profile.notifications.copyWith(onSuccess: value)));
  }

  Future<void> toggleNotifyOnError(bool value) async {
    await _saveProfile(profile.copyWith(notifications: profile.notifications.copyWith(onError: value)));
  }

  Future<void> toggleNotifyOnCompletion(bool value) async {
    await _saveProfile(profile.copyWith(notifications: profile.notifications.copyWith(onCompletion: value)));
  }

  Future<void> clearHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _workspaceRepository.clearAllRecords();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> exportHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final records = await _workspaceRepository.getAllRecords();
      final data = records.map((r) => r.toMap()).toList();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      final savePath = await FilePicker.saveFile(
        dialogTitle: 'Export History',
        fileName: 'dastra_history.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (savePath != null) {
        final file = File(savePath);
        await file.writeAsString(jsonString);
        return savePath;
      } else {
        // Fallback to exports dir if saveFile cancelled or unavailable
        final exportsDir = await _storage.getExportsDirectory();
        final defaultPath = p.join(exportsDir, 'dastra_history_${DateTime.now().millisecondsSinceEpoch}.json');
        await File(defaultPath).writeAsString(jsonString);
        return defaultPath;
      }
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
