import 'dart:typed_data';

enum CompressionStatus {
  pending,
  processing,
  success,
  failed,
}

/// Data model representing a single image compression task in Dastra.
class CompressionJob {
  const CompressionJob({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.originalFormat,
    required this.targetFormat,
    required this.resolution,
    this.status = CompressionStatus.pending,
    this.progress = 0.0,
    this.outputPath,
    this.compressedSize,
    this.error,
    this.bytes,
  });

  /// Unique identifier.
  final String id;

  /// Absolute file path.
  final String filePath;

  /// File name.
  final String fileName;

  /// Original file size in bytes.
  final int fileSize;

  /// Format e.g. 'jpg', 'png'.
  final String originalFormat;

  /// Target format for output e.g. 'jpg', 'png'.
  final String targetFormat;

  /// Dimensions e.g. '1920x1080'.
  final String resolution;

  /// Processing status.
  final CompressionStatus status;

  /// Process progress 0.0 - 1.0.
  final double progress;

  /// Path to compressed output file.
  final String? outputPath;

  /// Size of compressed output file in bytes.
  final int? compressedSize;

  /// Error message on failure.
  final String? error;

  /// Raw image bytes.
  final Uint8List? bytes;

  /// Space saved in bytes.
  int get spaceSaved {
    if (compressedSize == null || status != CompressionStatus.success) return 0;
    final diff = fileSize - compressedSize!;
    return diff > 0 ? diff : 0;
  }

  /// Percentage of size reduction.
  double get compressionRatio {
    if (fileSize <= 0 || compressedSize == null || status != CompressionStatus.success) return 0.0;
    final ratio = (fileSize - compressedSize!) / fileSize;
    return ratio > 0 ? ratio : 0.0;
  }

  CompressionJob copyWith({
    CompressionStatus? status,
    double? progress,
    String? outputPath,
    int? compressedSize,
    String? error,
    String? targetFormat,
    Uint8List? bytes,
  }) {
    return CompressionJob(
      id: id,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      originalFormat: originalFormat,
      targetFormat: targetFormat ?? this.targetFormat,
      resolution: resolution,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      compressedSize: compressedSize ?? this.compressedSize,
      error: error ?? this.error,
      bytes: bytes ?? this.bytes,
    );
  }
}
