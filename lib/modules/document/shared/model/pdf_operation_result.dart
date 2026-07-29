import 'dart:typed_data';

class PdfOutputFile {
  final String fileName;
  final Uint8List bytes;

  const PdfOutputFile({
    required this.fileName,
    required this.bytes,
  });
}

class PdfOperationResult {
  final List<PdfOutputFile> files;
  final String? error;
  final bool needsEngineDownload;
  final String? requiredEngineId;
  
  bool get isSuccess => error == null && files.isNotEmpty;
  bool get hasMultipleFiles => files.length > 1;

  const PdfOperationResult.success(this.files) 
      : error = null, 
        needsEngineDownload = false, 
        requiredEngineId = null;

  const PdfOperationResult.failure(
    this.error, {
    this.needsEngineDownload = false,
    this.requiredEngineId,
  }) : files = const [];
}
