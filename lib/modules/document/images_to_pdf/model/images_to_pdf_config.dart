enum PdfPageSize {
  original,
  a4,
  letter,
  legal,
}

enum PdfPageOrientation {
  auto,
  portrait,
  landscape,
}

enum ImageFitMode {
  fitEntireImage, // Maintain aspect ratio, fit within page
  fillPage,       // Fill page completely, may crop
  originalSize,   // Don't resize image, just draw it (may overflow or be tiny)
}

enum PdfQuality {
  high,       // 100% quality (no compression)
  medium,     // 70% quality
  smallFile,  // 40% quality
}

class ImagesToPdfConfig {
  final PdfPageSize pageSize;
  final PdfPageOrientation orientation;
  final ImageFitMode fitMode;
  final PdfQuality quality;
  final double margin;
  final String outputFileName;

  const ImagesToPdfConfig({
    this.pageSize = PdfPageSize.a4,
    this.orientation = PdfPageOrientation.auto,
    this.fitMode = ImageFitMode.fitEntireImage,
    this.quality = PdfQuality.high,
    this.margin = 16.0,
    this.outputFileName = 'document',
  });

  ImagesToPdfConfig copyWith({
    PdfPageSize? pageSize,
    PdfPageOrientation? orientation,
    ImageFitMode? fitMode,
    PdfQuality? quality,
    double? margin,
    String? outputFileName,
  }) {
    return ImagesToPdfConfig(
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      fitMode: fitMode ?? this.fitMode,
      quality: quality ?? this.quality,
      margin: margin ?? this.margin,
      outputFileName: outputFileName ?? this.outputFileName,
    );
  }
}
