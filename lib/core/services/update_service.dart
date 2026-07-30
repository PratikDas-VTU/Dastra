import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Represents the status of the update process.
enum UpdateStatus {
  idle,
  checking,
  available,
  downloading,
  readyToInstall,
  upToDate,
  error,
}

/// A data class representing information about an available update.
class UpdateInfo {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool isCritical;

  const UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    this.isCritical = false,
  });
}

/// Abstract service to handle application updates.
/// 
/// This provides the foundation for future auto-update capabilities.
/// Future implementations could integrate with WinGet, Chocolatey, or 
/// custom backend APIs.
abstract class UpdateService extends ChangeNotifier {
  UpdateStatus _status = UpdateStatus.idle;
  UpdateInfo? _availableUpdate;
  String? _errorMessage;
  double _downloadProgress = 0.0;

  UpdateStatus get status => _status;
  UpdateInfo? get availableUpdate => _availableUpdate;
  String? get errorMessage => _errorMessage;
  double get downloadProgress => _downloadProgress;

  /// Retrieves current application version information.
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Checks for available updates against a remote server or repository.
  Future<void> checkForUpdates();

  /// Initiates the download of the available update.
  Future<void> downloadUpdate();

  /// Triggers the installation of the downloaded update.
  /// This typically involves launching the installer and exiting the app.
  Future<void> installUpdate();

  @protected
  void setStatus(UpdateStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @protected
  void setAvailableUpdate(UpdateInfo? info) {
    _availableUpdate = info;
    notifyListeners();
  }

  @protected
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  @protected
  void setDownloadProgress(double progress) {
    _downloadProgress = progress;
    notifyListeners();
  }
}

/// A mock implementation of the UpdateService for development and testing.
class MockUpdateService extends UpdateService {
  @override
  Future<void> checkForUpdates() async {
    setStatus(UpdateStatus.checking);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate finding an update (for demonstration purposes)
    setAvailableUpdate(const UpdateInfo(
      version: '1.1.0',
      releaseNotes: 'Performance improvements and bug fixes.',
      downloadUrl: 'https://github.com/PratikDas-VTU/Dastra/releases/latest',
      isCritical: false,
    ));
    
    setStatus(UpdateStatus.available);
  }

  @override
  Future<void> downloadUpdate() async {
    if (status != UpdateStatus.available || availableUpdate == null) return;
    
    setStatus(UpdateStatus.downloading);
    setDownloadProgress(0.0);
    
    // Simulate download progress
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setDownloadProgress(i / 10.0);
    }
    
    setStatus(UpdateStatus.readyToInstall);
  }

  @override
  Future<void> installUpdate() async {
    if (status != UpdateStatus.readyToInstall) return;
    
    // In a real scenario, this would launch DastraSetup.exe /SILENT 
    // and then call exit(0) to close the current application.
    debugPrint('Executing installer from temp directory...');
  }
}
