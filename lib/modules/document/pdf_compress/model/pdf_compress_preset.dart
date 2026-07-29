enum PdfCompressPreset {
  low('Low Compression', 'low', 'Minimal size reduction, lossless'),
  medium('Medium Compression', 'medium', 'Good balance of quality and size'),
  high('High Compression', 'high', 'Significant size reduction'),
  max('Maximum Compression', 'max', 'Smallest file size possible');

  final String label;
  final String key;
  final String description;

  const PdfCompressPreset(this.label, this.key, this.description);
}
