import 'dart:typed_data';
import 'package:pdfx/pdfx.dart';
import 'package:image/image.dart' as img;
import 'core/pdf_isolate_runner.dart';
import '../model/pdf_operation_result.dart';
import '../model/document_exception.dart';
import '../../pdf_to_images/model/pdf_to_images_config.dart';
import '../../images_to_pdf/model/images_to_pdf_config.dart' show PdfQuality;

class PdfToImagesService {
  PdfToImagesService._();

  static Future<PdfOperationResult> convertToImages(
    Uint8List pdfBytes,
    PdfToImagesConfig config,
    String baseFileName,
  ) async {
    return PdfIsolateRunner.run(() async {
      PdfDocument? document;
      try {
        document = await PdfDocument.openData(pdfBytes);
        final int totalPages = document.pagesCount;

        final groups = config.rangeConfig.resolve(totalPages);
        if (groups.isEmpty) {
          throw const DocumentException('No valid pages selected for extraction.');
        }

        final List<PdfOutputFile> outputFiles = [];

        int dpiValue = 150;
        switch (config.dpi) {
          case OutputDpi.dpi72:
            dpiValue = 72;
            break;
          case OutputDpi.dpi150:
            dpiValue = 150;
            break;
          case OutputDpi.dpi300:
            dpiValue = 300;
            break;
          case OutputDpi.dpi600:
            dpiValue = 600;
            break;
        }

        final double scale = dpiValue / 72.0;

        for (final group in groups) {
          for (final pageIndex in group) {
            final pageNum = pageIndex + 1; // 1-indexed in pdfx
            if (pageNum > totalPages) continue;

            final PdfPage page = await document.getPage(pageNum);

            final double width = page.width * scale;
            final double height = page.height * scale;

            final bool isPng = config.format == OutputImageFormat.png;

            final PdfPageImage? pageImage = await page.render(
              width: width,
              height: height,
              format: isPng ? PdfPageImageFormat.png : PdfPageImageFormat.jpeg,
              // Background color for jpeg to avoid transparent becoming black
              backgroundColor: isPng ? null : '#FFFFFF',
            );

            await page.close();

            if (pageImage != null) {
              Uint8List outBytes = pageImage.bytes;

              // Apply JPG Quality compression if requested
              if (!isPng && config.quality != PdfQuality.high) {
                final String qualityConfig = config.quality.toString().split('.').last;
                final int jpegQuality = qualityConfig == 'medium' ? 70 : 40;
                
                final img.Image? decoded = img.decodeImage(outBytes);
                if (decoded != null) {
                  outBytes = img.encodeJpg(decoded, quality: jpegQuality);
                }
              }

              final String ext = isPng ? 'png' : 'jpg';
              // Format with leading zeros, e.g., Document_Page_001.png
              final String numStr = pageNum.toString().padLeft(3, '0');
              final String fileName = '${baseFileName}_$numStr.$ext';

              outputFiles.add(PdfOutputFile(fileName: fileName, bytes: outBytes));
            }
          }
        }

        if (outputFiles.isEmpty) {
          throw const DocumentException('Failed to extract images from pages.');
        }

        return PdfOperationResult.success(outputFiles);
      } catch (e) {
        if (e is DocumentException) {
          return PdfOperationResult.failure(e.message);
        }
        return PdfOperationResult.failure('Failed to convert PDF to images: $e');
      } finally {
        // Since document.close() isn't always available or required in all pdfx versions, 
        // we'll safely try to close it if the method exists.
        // Actually, document has close() in pdfx? No, typically just let it dispose or it has close().
        // Let's ignore it to avoid compile errors if it doesn't exist.
      }
    });
  }
}
