import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'core/pdf_isolate_runner.dart';

class PdfCoreService {
  PdfCoreService._();

  /// Retrieves the number of pages in a PDF document.
  static Future<int> getPageCount(Uint8List bytes) async {
    return PdfIsolateRunner.run(() {
      try {
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        final int count = document.pages.count;
        document.dispose();
        return count;
      } catch (e) {
        return 0;
      }
    });
  }
}
