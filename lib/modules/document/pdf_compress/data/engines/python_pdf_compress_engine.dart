import 'dart:async';
import 'dart:io';
import '../../domain/pdf_compress_engine.dart';
import '../../model/pdf_compress_preset.dart';
import '../../../../../core/engine/manager/engine_manager.dart';
import '../../../../../core/storage/storage_service.dart';

class PythonPdfCompressEngine extends PdfCompressEngine {
  final EngineManager manager;
  final StorageService storageService;

  PythonPdfCompressEngine(this.manager, this.storageService);

  @override
  String get engineId => 'org.dastra.engine.pdfcompress';

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
    final scriptFile = File(storageService.getEngineAssetPath('pdf_compress/compress.py'));
    return await scriptFile.exists();
  }

  @override
  Future<String> engineVersion() async => '1.0.0-python-pymupdf';

  @override
  List<String> get supportedCapabilities => [
    'PyMuPDF Compression', 'Garbage Collection', 'Deflate', 'Offline'
  ];

  @override
  Future<void> compress(File input, File output, PdfCompressPreset preset, {StreamController<double>? progress}) async {
    progress?.add(0.1);
    
    if (!await healthCheck()) {
      throw Exception('Python Engine failed health check. compress.py not found or Python not installed.');
    }
    
    progress?.add(0.3);
    
    final scriptPath = storageService.getEngineAssetPath('pdf_compress/compress.py');
    
    final result = await Process.run('python', [
      scriptPath,
      input.absolute.path,
      output.absolute.path,
      '--level',
      preset.key,
    ]);
    
    progress?.add(0.9);
    
    if (result.exitCode != 0) {
      throw Exception("Compression Engine failed: ${result.stderr} \nStdout: ${result.stdout}");
    }
    
    if (!await output.exists()) {
      throw Exception('Output file was not generated.');
    }
    
    progress?.add(1.0);
  }
}
