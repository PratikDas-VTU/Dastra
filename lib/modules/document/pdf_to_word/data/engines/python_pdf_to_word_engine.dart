import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../domain/pdf_to_word_engine.dart';
import '../../../../../core/engine/manager/engine_manager.dart';
import '../../../../../core/storage/storage_service.dart';

class PythonPdfToWordEngine extends PdfToWordEngine {
  final EngineManager manager;
  final StorageService storageService;

  PythonPdfToWordEngine(this.manager, this.storageService);

  @override
  String get engineId => 'org.dastra.engine.pdf2docx';

  @override
  Future<bool> isAvailable() async {
    try {
      final res = await Process.run('python', ['--version']).timeout(const Duration(seconds: 2));
      return res.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> healthCheck() async {
    if (!await isAvailable()) return false;
    final scriptFile = File(storageService.getEngineAssetPath('pdf2docx/convert.py'));
    return await scriptFile.exists();
  }

  @override
  Future<String> engineVersion() async => '1.0.0-python-pdf2docx';

  @override
  List<String> get supportedCapabilities => [
    'Tables', 'Images', 'Paragraph Formatting', 'Fonts', 'Offline'
  ];

  @override
  Future<void> convertPdfToWord(File input, File output, {StreamController<double>? progress}) async {
    progress?.add(0.1);
    
    if (!await healthCheck()) {
      throw Exception('Python Engine failed health check. convert.py not found or Python not installed.');
    }
    
    progress?.add(0.3);
    
    final scriptPath = storageService.getEngineAssetPath('pdf2docx/convert.py');
    
    final result = await Process.run('python', [
      scriptPath,
      input.absolute.path,
      output.absolute.path,
    ]);
    
    progress?.add(0.9);
    
    if (result.exitCode != 0) {
      throw Exception("Python Engine failed: ${result.stderr} \nStdout: ${result.stdout}");
    }
    
    try {
      final jsonResponse = jsonDecode(result.stdout as String);
      if (jsonResponse['error'] != null) {
        throw Exception("Engine Error: ${jsonResponse['error']}");
      }
    } catch (_) {
      // Ignored if output isn't perfect JSON
    }
    
    if (!await output.exists()) {
      throw Exception('Output file was not generated.');
    }
    
    progress?.add(1.0);
  }
}
