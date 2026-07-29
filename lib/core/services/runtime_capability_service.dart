import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/tool_item.dart';

class RuntimeCapabilityService extends ChangeNotifier {
  final Map<String, bool> _capabilityCache = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Perform initial detection
    await _detectRuntimes();
    
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> refresh() async {
    _isInitialized = false;
    notifyListeners();
    await init();
  }

  Future<void> _detectRuntimes() async {
    // Basic checks
    if (Platform.isWindows) {
      _capabilityCache['python'] = await _checkCommand('python', ['--version']);
      _capabilityCache['libreoffice'] = await _checkWindowsLibreOffice();
      _capabilityCache['windows_com'] = true; // Native to Windows
    } else if (Platform.isMacOS || Platform.isLinux) {
      _capabilityCache['python'] = await _checkCommand('python3', ['--version']);
      _capabilityCache['libreoffice'] = await _checkCommand('libreoffice', ['--version']);
      _capabilityCache['windows_com'] = false;
    } else {
      // Mobile platforms typically don't have these
      _capabilityCache['python'] = false;
      _capabilityCache['libreoffice'] = false;
      _capabilityCache['windows_com'] = false;
    }
  }

  Future<bool> _checkCommand(String command, List<String> args) async {
    try {
      final result = await Process.run(command, args).timeout(const Duration(seconds: 2));
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkWindowsLibreOffice() async {
    // Check common installation paths
    final paths = [
      r'C:\Program Files\LibreOffice\program\soffice.exe',
      r'C:\Program Files (x86)\LibreOffice\program\soffice.exe',
    ];
    for (final path in paths) {
      if (await File(path).exists()) return true;
    }
    // Fallback to checking PATH
    return _checkCommand('soffice', ['--version']);
  }

  bool isToolSupported(ToolItem tool) {
    if (!_isInitialized) return true; // Optimistic return before initialization

    // Check Platform Support
    if (tool.supportedPlatforms != null && !tool.supportedPlatforms!.contains(defaultTargetPlatform)) {
      return false;
    }

    // Check Runtimes
    for (final runtime in tool.requiredRuntimes) {
      if (_capabilityCache[runtime] == false) {
        return false;
      }
    }

    return true;
  }

  String? getUnsupportedReason(ToolItem tool) {
    if (!_isInitialized) return null;

    if (tool.supportedPlatforms != null && !tool.supportedPlatforms!.contains(defaultTargetPlatform)) {
      return 'Requires Desktop Platform'; 
    }

    for (final runtime in tool.requiredRuntimes) {
      if (_capabilityCache[runtime] == false) {
        if (runtime == 'python') return 'Requires Python installed';
        if (runtime == 'libreoffice') return 'Requires LibreOffice';
        if (runtime == 'windows_com') return 'Requires Microsoft Office';
        return 'Requires $runtime';
      }
    }

    return null;
  }
}
