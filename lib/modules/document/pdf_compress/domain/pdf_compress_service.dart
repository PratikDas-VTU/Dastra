import 'dart:async';
import 'dart:io';
import '../../../../core/engine/registry/engine_registry.dart';
import '../../shared/model/pdf_operation_result.dart';
import '../model/pdf_compress_preset.dart';
import 'pdf_compress_engine.dart';

class PdfCompressService {
  final EngineRegistry _registry;

  PdfCompressService(this._registry);

  Future<PdfCompressEngine?> resolveEngine() async {
    return await _registry.resolve<PdfCompressEngine>();
  }

  Future<PdfOperationResult> compressPdf(
    File input,
    String outputFileName,
    PdfCompressPreset preset, {
    StreamController<double>? progress,
  }) async {
    try {
      final engine = await _registry.resolve<PdfCompressEngine>();
      
      if (engine == null) {
        return const PdfOperationResult.failure(
          'No PDF Compress engine is available.',
          needsEngineDownload: true,
          requiredEngineId: 'org.dastra.engine.pdfcompress',
        );
      }

      final outPath = '${input.parent.absolute.path}/$outputFileName';
      final outFile = File(outPath);

      await engine.compress(input, outFile, preset, progress: progress);

      final bytes = await outFile.readAsBytes();

      if (await outFile.exists()) {
        await outFile.delete();
      }

      return PdfOperationResult.success([
        PdfOutputFile(fileName: outputFileName, bytes: bytes)
      ]);
    } catch (e) {
      return PdfOperationResult.failure('Compression failed: $e');
    }
  }
}
