import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'core/pdf_isolate_runner.dart';
import '../model/document_exception.dart';

class PdfMergeService {
  PdfMergeService._();

  /// Merges multiple PDF byte arrays into a single PDF document.
  static Future<Uint8List> mergePdfs(List<Uint8List> pdfsBytes) async {
    return PdfIsolateRunner.run(() {
      if (pdfsBytes.isEmpty) {
        throw const DocumentException('No PDFs provided for merging');
      }

      final PdfDocument outputDocument = PdfDocument();
      final List<PdfDocument> inputDocuments = [];

      try {
        for (final bytes in pdfsBytes) {
          final PdfDocument inputDocument = PdfDocument(inputBytes: bytes);
          inputDocuments.add(inputDocument);
          
          for (int i = 0; i < inputDocument.pages.count; i++) {
            final PdfPage sourcePage = inputDocument.pages[i];
            
            outputDocument.pageSettings.size = sourcePage.size;
            outputDocument.pageSettings.margins.all = 0;
            outputDocument.pageSettings.rotate = sourcePage.rotation;
            
            final PdfPage newPage = outputDocument.pages.add();
            final PdfTemplate template = sourcePage.createTemplate();
            
            newPage.graphics.drawPdfTemplate(template, Offset.zero);
          }
        }

        final List<int> savedBytes = outputDocument.saveSync();
        return Uint8List.fromList(savedBytes);
      } catch (e) {
        throw DocumentException('Failed to merge PDFs: $e');
      } finally {
        for (final doc in inputDocuments) {
          doc.dispose();
        }
        outputDocument.dispose();
      }
    });
  }
}
