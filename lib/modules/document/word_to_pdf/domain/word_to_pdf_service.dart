import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/engine/registry/engine_registry.dart';
import '../../shared/model/pdf_operation_result.dart';
import 'word_to_pdf_engine.dart';

class WordToPdfService {
  final EngineRegistry _registry;

  WordToPdfService(this._registry);

  Future<WordToPdfEngine?> resolveEngine() async {
    return await _registry.resolve<WordToPdfEngine>();
  }

  Future<PdfOperationResult> convertWordToPdf(
    File input,
    String outputFileName, {
    StreamController<double>? progress,
  }) async {
    try {
      final engine = await _registry.resolve<WordToPdfEngine>();
      
      if (engine == null) {
        return const PdfOperationResult.failure(
          'No Word to PDF engine is available.',
          needsEngineDownload: true,
          requiredEngineId: 'org.libreoffice.headless',
        );
      }

      final outPath = '${input.parent.absolute.path}/$outputFileName';
      final outFile = File(outPath);

      await engine.convert(input, outFile, progress: progress);

      Uint8List? bytes;
      for (int i = 0; i < 5; i++) {
        try {
          bytes = await outFile.readAsBytes();
          break;
        } catch (e) {
          if (i == 4) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (await outFile.exists()) {
        try {
          await outFile.delete();
        } catch (_) {}
      }

      return PdfOperationResult.success([
        PdfOutputFile(fileName: outputFileName, bytes: bytes!)
      ]);
    } catch (e) {
      return PdfOperationResult.failure('Conversion failed: $e');
    }
  }
}
