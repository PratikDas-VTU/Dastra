class SuccessScreenData {
  final String outputFilename;
  final String outputPath;
  final int originalSizeBytes;
  final int finalSizeBytes;
  final int processingTimeMs;

  SuccessScreenData({
    required this.outputFilename,
    required this.outputPath,
    required this.originalSizeBytes,
    required this.finalSizeBytes,
    required this.processingTimeMs,
  });

  double get percentageReduction {
    if (originalSizeBytes == 0) return 0;
    final diff = originalSizeBytes - finalSizeBytes;
    if (diff <= 0) return 0;
    return (diff / originalSizeBytes) * 100;
  }
}
