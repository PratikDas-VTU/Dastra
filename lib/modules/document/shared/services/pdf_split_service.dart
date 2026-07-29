import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'core/pdf_isolate_runner.dart';
import '../model/pdf_operation_result.dart';
import '../model/document_exception.dart';

class PdfSplitService {
  PdfSplitService._();

  /// Splits a single PDF into multiple PDFs based on page groups.
  static Future<PdfOperationResult> splitPdf(
    Uint8List bytes, 
    String originalName, 
    List<List<int>> pageGroups
  ) async {
    return PdfIsolateRunner.run(() {
      try {
        final PdfDocument inputDocument = PdfDocument(inputBytes: bytes);
        final int totalPages = inputDocument.pages.count;
        
        final List<PdfOutputFile> outputFiles = [];
        
        final nameWithoutExt = originalName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

        for (int i = 0; i < pageGroups.length; i++) {
          final group = pageGroups[i];
          if (group.isEmpty) continue;

          final PdfDocument outputDocument = PdfDocument();
          
          for (final pageIndex in group) {
            if (pageIndex < 0 || pageIndex >= totalPages) continue;
            
            final PdfPage sourcePage = inputDocument.pages[pageIndex];
            
            outputDocument.pageSettings.size = sourcePage.size;
            outputDocument.pageSettings.margins.all = 0;
            outputDocument.pageSettings.rotate = sourcePage.rotation;
            
            final PdfPage newPage = outputDocument.pages.add();
            final PdfTemplate template = sourcePage.createTemplate();
            newPage.graphics.drawPdfTemplate(template, Offset.zero);
          }

          if (outputDocument.pages.count > 0) {
            final savedBytes = outputDocument.saveSync();
            final outName = pageGroups.length == 1 
                ? '${nameWithoutExt}_split.pdf' 
                : '${nameWithoutExt}_part_${i + 1}.pdf';
                
            outputFiles.add(PdfOutputFile(
              fileName: outName, 
              bytes: Uint8List.fromList(savedBytes),
            ));
          }
          outputDocument.dispose();
        }
        
        inputDocument.dispose();
        
        if (outputFiles.isEmpty) {
          throw const DocumentException('No valid pages found to extract.');
        }
        return PdfOperationResult.success(outputFiles);
      } catch (e) {
        if (e is DocumentException) {
          return PdfOperationResult.failure(e.message);
        }
        return PdfOperationResult.failure('Failed to split PDF: $e');
      }
    });
  }
}
