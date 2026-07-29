import 'dart:typed_data';

enum DocumentStatus {
  pending,
  reading,
  processing,
  saving,
  success,
  failed,
}

/// A generic data model for document processing tasks (Merge, Split, Compress, etc.)
class DocumentJob {
  const DocumentJob({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.pageCount,
    this.status = DocumentStatus.pending,
    this.progress = 0.0,
    this.outputPath,
    this.processedSize,
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

  /// Number of pages in the document (if applicable/parsed).
  final int? pageCount;

  /// Current processing status.
  final DocumentStatus status;

  /// Processing progress 0.0 - 1.0.
  final double progress;

  /// Path to the output file (if saved to disk).
  final String? outputPath;

  /// Size of the resulting processed file.
  final int? processedSize;

  /// Error message on failure.
  final String? error;

  /// Raw bytes (especially for Web).
  final Uint8List? bytes;

  DocumentJob copyWith({
    DocumentStatus? status,
    double? progress,
    int? pageCount,
    String? outputPath,
    int? processedSize,
    String? error,
    Uint8List? bytes,
  }) {
    return DocumentJob(
      id: id,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      pageCount: pageCount ?? this.pageCount,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      processedSize: processedSize ?? this.processedSize,
      error: error ?? this.error,
      bytes: bytes ?? this.bytes,
    );
  }
}
