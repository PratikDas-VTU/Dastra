import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PdfIsolateRunner {
  PdfIsolateRunner._();

  /// Runs the heavy document operation.
  /// Uses [Isolate.run] on Desktop/Mobile to avoid blocking the main thread.
  /// On Web, runs synchronously as isolates are not supported in dart4web.
  static Future<R> run<R>(FutureOr<R> Function() computation) async {
    if (kIsWeb) {
      return computation();
    }
    final RootIsolateToken? rootToken = RootIsolateToken.instance;
    return Isolate.run(() {
      if (rootToken != null) {
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
      }
      return computation();
    });
  }
}
