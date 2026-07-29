import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class FileLauncher {
  static const MethodChannel _channel = MethodChannel('com.dastra.app/file_utils');

  static Future<void> openFile(String path) async {
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openFile', {'path': path});
      } catch (e) {
        debugPrint('Error opening file on Android: $e');
      }
    } else if (Platform.isWindows) {
      Process.run('explorer', [path]);
    } else {
      final uri = Uri.file(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  static Future<void> openFolder(String path) async {
    if (kIsWeb) return;
    
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('openFolder', {'path': path});
      } catch (e) {
        debugPrint('Error opening folder on Android: $e');
      }
    } else if (Platform.isWindows) {
      Process.run('explorer', ['/select,', path]);
    } else {
      final uri = Uri.directory(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }
}
