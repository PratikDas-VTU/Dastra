import 'dart:async';
import 'dart:io';
import '../../../../core/engine/contracts/abstract_engine.dart';
import '../model/pdf_compress_preset.dart';

abstract class PdfCompressEngine extends AbstractEngine {
  /// Compresses a PDF file based on the preset.
  /// [input] is the original PDF file.
  /// [output] is the destination PDF file.
  /// [preset] is the compression level.
  /// [progress] is an optional stream controller to report progress (0.0 to 1.0).
  Future<void> compress(File input, File output, PdfCompressPreset preset, {StreamController<double>? progress});
}
