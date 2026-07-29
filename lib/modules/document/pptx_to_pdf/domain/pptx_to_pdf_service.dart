import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/engine/registry/engine_registry.dart';
import '../../shared/model/pdf_operation_result.dart';
import 'pptx_to_pdf_engine.dart';

class PptxToPdfService {
  final EngineRegistry _registry;

  PptxToPdfService(this._registry);

  Future<PptxToPdfEngine?> resolveEngine() async {
    return await _registry.resolve<PptxToPdfEngine>();
  }

  Future<PdfOperationResult> convertPptxToPdf(
    File inputFile, 
    String outputFileName,
    {StreamController<double>? progress}
  ) async {
    try {
      final engine = await resolveEngine();
      
      if (engine == null) {
        return const PdfOperationResult.failure(
          'No engine installed.', 
          needsEngineDownload: true, 
          requiredEngineId: 'org.libreoffice.headless'
        );
      }

      final outName = outputFileName.endsWith('.pdf') ? outputFileName : '$outputFileName.pdf';
      final outPath = '${inputFile.parent.absolute.path}/$outName';
      final outFile = File(outPath);

      await engine.convert(inputFile, outFile, progress: progress);

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
        PdfOutputFile(fileName: outName, bytes: bytes!)
      ]);
    } catch (e) {
      return PdfOperationResult.failure('Failed to convert PPTX to PDF: $e');
    }
  }
}
