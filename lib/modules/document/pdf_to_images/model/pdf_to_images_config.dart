import '../../shared/model/split_config.dart';
import '../../images_to_pdf/model/images_to_pdf_config.dart' show PdfQuality;

enum OutputImageFormat {
  png,
  jpg,
}

enum OutputDpi {
  dpi72,
  dpi150,
  dpi300,
  dpi600,
}

class PdfToImagesConfig {
  final OutputImageFormat format;
  final OutputDpi dpi;
  final PdfQuality quality; // Used only for JPG
  final SplitConfig rangeConfig;
  final String outputFileName;

  const PdfToImagesConfig({
    this.format = OutputImageFormat.png,
    this.dpi = OutputDpi.dpi150,
    this.quality = PdfQuality.high,
    this.rangeConfig = const ExtractAllSplitConfig(),
    this.outputFileName = 'Document_Page',
  });

  PdfToImagesConfig copyWith({
    OutputImageFormat? format,
    OutputDpi? dpi,
    PdfQuality? quality,
    SplitConfig? rangeConfig,
    String? outputFileName,
  }) {
    return PdfToImagesConfig(
      format: format ?? this.format,
      dpi: dpi ?? this.dpi,
      quality: quality ?? this.quality,
      rangeConfig: rangeConfig ?? this.rangeConfig,
      outputFileName: outputFileName ?? this.outputFileName,
    );
  }
}
