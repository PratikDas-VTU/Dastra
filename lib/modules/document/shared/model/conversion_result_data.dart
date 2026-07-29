class ConversionStatistic {
  final String label;
  final String value;

  const ConversionStatistic(this.label, this.value);
}

class ConversionResultData {
  final String outputFilename;
  final String outputPath;
  final String outputFolder;
  final int processingTimeMs;
  final String? errorMessage;
  final List<ConversionStatistic> statistics;

  bool get isSuccess => errorMessage == null;

  const ConversionResultData({
    required this.outputFilename,
    required this.outputPath,
    required this.outputFolder,
    required this.processingTimeMs,
    this.errorMessage,
    this.statistics = const [],
  });
}
