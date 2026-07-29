import 'dart:async';
import 'dart:io';
import '../../../../core/engine/registry/engine_registry.dart';
import '../../shared/model/pdf_operation_result.dart';
import 'pdf_to_word_engine.dart';
import '../../../../core/premium/feature_gate_service.dart';
import '../../../../core/utils/tool_registry.dart';

class PdfToWordService {
  final EngineRegistry _registry;
  final FeatureGateService _featureGateService;

  PdfToWordService(this._registry, this._featureGateService);

  Future<PdfToWordEngine?> resolveEngine() async {
    return await _registry.resolve<PdfToWordEngine>();
  }

  Future<PdfOperationResult> convertPdfToWord(
    File inputFile, 
    String outputFileName,
    {StreamController<double>? progress}
  ) async {
    _featureGateService.ensureAccess(ToolIds.pdfToWord);
    try {
      final engine = await resolveEngine();
      
      if (engine == null) {
        return const PdfOperationResult.failure(
          'No engine installed.', 
          needsEngineDownload: true, 
          requiredEngineId: 'org.dastra.engine.pdf2docx'
        );
      }

      final outName = outputFileName.endsWith('.docx') ? outputFileName : '$outputFileName.docx';
      final outPath = '${inputFile.parent.absolute.path}/$outName';
      final outFile = File(outPath);

      await engine.convertPdfToWord(inputFile, outFile, progress: progress);

      final bytes = await outFile.readAsBytes();
      
      if (await outFile.exists()) {
        await outFile.delete();
      }

      return PdfOperationResult.success([
        PdfOutputFile(fileName: outName, bytes: bytes)
      ]);
    } catch (e) {
      return PdfOperationResult.failure('Failed to convert PDF to Word: $e');
    }
  }
}
