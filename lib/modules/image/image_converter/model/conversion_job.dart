import 'dart:typed_data';

/// Status of a file conversion process.
enum ConversionStatus {
  pending,
  processing,
  success,
  failed,
}

/// Data model representing a single image conversion task in Dastra.
class ConversionJob {
  const ConversionJob({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.originalFormat,
    required this.targetFormat,
    required this.resolution,
    this.status = ConversionStatus.pending,
    this.progress = 0.0,
    this.error,
    this.outputPath,
    this.bytes,
  });

  /// Unique identifier for tracking.
  final String id;

  /// Input file absolute path.
  final String filePath;

  /// Input file name.
  final String fileName;

  /// Size of file in bytes.
  final int fileSize;

  /// Source format ('jpg', 'jpeg', 'png').
  final String originalFormat;

  /// Destination format ('jpg', 'png').
  final String targetFormat;

  /// Display string (e.g. '1920x1080') or 'Unknown'.
  final String resolution;

  /// Progress state.
  final ConversionStatus status;

  /// Progression value 0.0–1.0.
  final double progress;

  /// Error message when conversion fails.
  final String? error;

  /// Completed output file path.
  final String? outputPath;

  /// Raw image bytes (used on Web and for in-memory processing).
  final Uint8List? bytes;

  /// Produces a copy with overridden fields.
  ConversionJob copyWith({
    ConversionStatus? status,
    double? progress,
    String? error,
    String? outputPath,
    String? targetFormat,
    Uint8List? bytes,
  }) {
    return ConversionJob(
      id: id,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      originalFormat: originalFormat,
      targetFormat: targetFormat ?? this.targetFormat,
      resolution: resolution,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      outputPath: outputPath ?? this.outputPath,
      bytes: bytes ?? this.bytes,
    );
  }
}
