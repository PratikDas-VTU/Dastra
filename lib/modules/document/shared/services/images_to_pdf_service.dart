import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:image/image.dart' as img;
import 'core/pdf_isolate_runner.dart';
import '../model/pdf_operation_result.dart';
import '../../images_to_pdf/model/images_to_pdf_config.dart' as cfg;

class ImagesToPdfService {
  ImagesToPdfService._();

  /// Converts a list of images (bytes) into a single PDF document.
  static Future<PdfOperationResult> imagesToPdf(
    List<Uint8List> images,
    cfg.ImagesToPdfConfig config,
    String outFileName,
  ) async {
    return PdfIsolateRunner.run(() {
      try {
        final PdfDocument document = PdfDocument();
        
        document.pageSettings.setMargins(0);

        for (final imageBytes in images) {
          Uint8List processBytes = imageBytes;
          
          final String qualityConfig = config.quality.toString().split('.').last;
          if (qualityConfig == 'medium' || qualityConfig == 'smallFile') {
            final int jpegQuality = qualityConfig == 'medium' ? 70 : 40;
            final img.Image? decoded = img.decodeImage(processBytes);
            if (decoded != null) {
              processBytes = img.encodeJpg(decoded, quality: jpegQuality);
            }
          }
          
          final PdfBitmap bitmap = PdfBitmap(processBytes);
          
          final double imgWidth = bitmap.width.toDouble();
          final double imgHeight = bitmap.height.toDouble();
          
          Size pageSize;
          final String sizeConfig = config.pageSize.toString().split('.').last;
          switch (sizeConfig) {
            case 'a4':
              pageSize = PdfPageSize.a4;
              break;
            case 'letter':
              pageSize = PdfPageSize.letter;
              break;
            case 'legal':
              pageSize = PdfPageSize.legal;
              break;
            case 'original':
            default:
              pageSize = Size(imgWidth, imgHeight);
              break;
          }

          final String oriConfig = config.orientation.toString().split('.').last;
          PdfPageOrientation orientation = PdfPageOrientation.portrait;
          if (oriConfig == 'landscape') {
            orientation = PdfPageOrientation.landscape;
          } else if (oriConfig == 'auto') {
            if (sizeConfig != 'original') {
              orientation = imgWidth > imgHeight 
                  ? PdfPageOrientation.landscape 
                  : PdfPageOrientation.portrait;
            }
          }
          
          document.pageSettings.size = pageSize;
          document.pageSettings.orientation = orientation;
          
          final PdfPage page = document.pages.add();
          final Size actualPageSize = page.getClientSize();
          
          page.graphics.drawRectangle(
            brush: PdfBrushes.white,
            bounds: Rect.fromLTWH(0, 0, actualPageSize.width, actualPageSize.height)
          );

          final double margin = config.margin;
          final double availWidth = actualPageSize.width - (margin * 2);
          final double availHeight = actualPageSize.height - (margin * 2);
          
          Rect drawRect;
          final String fitConfig = config.fitMode.toString().split('.').last;
          
          if (sizeConfig == 'original') {
            drawRect = Rect.fromLTWH(margin, margin, availWidth, availHeight);
          } else {
            if (fitConfig == 'fitEntireImage') {
              final double ratioX = availWidth / imgWidth;
              final double ratioY = availHeight / imgHeight;
              final double ratio = ratioX < ratioY ? ratioX : ratioY;
              final double drawW = imgWidth * ratio;
              final double drawH = imgHeight * ratio;
              final double drawX = margin + (availWidth - drawW) / 2;
              final double drawY = margin + (availHeight - drawH) / 2;
              drawRect = Rect.fromLTWH(drawX, drawY, drawW, drawH);
            } else if (fitConfig == 'fillPage') {
              final double ratioX = availWidth / imgWidth;
              final double ratioY = availHeight / imgHeight;
              final double ratio = ratioX > ratioY ? ratioX : ratioY;
              final double drawW = imgWidth * ratio;
              final double drawH = imgHeight * ratio;
              final double drawX = margin + (availWidth - drawW) / 2;
              final double drawY = margin + (availHeight - drawH) / 2;
              drawRect = Rect.fromLTWH(drawX, drawY, drawW, drawH);
            } else {
              final double drawX = margin + (availWidth - imgWidth) / 2;
              final double drawY = margin + (availHeight - imgHeight) / 2;
              drawRect = Rect.fromLTWH(drawX, drawY, imgWidth, imgHeight);
            }
          }

          page.graphics.drawImage(bitmap, drawRect);
        }

        final List<int> savedBytes = document.saveSync();
        document.dispose();
        
        final outName = outFileName.endsWith('.pdf') ? outFileName : '$outFileName.pdf';

        return PdfOperationResult.success([
          PdfOutputFile(fileName: outName, bytes: Uint8List.fromList(savedBytes))
        ]);
      } catch (e) {
        return PdfOperationResult.failure('Failed to convert images to PDF: $e');
      }
    });
  }
}
