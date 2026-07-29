import 'dart:async';
import 'dart:io';
import '../../../../core/engine/contracts/abstract_engine.dart';

abstract class PptxToPdfEngine extends AbstractEngine {
  /// Converts a PPTX file to a PDF file.
  /// [input] is the PPTX file to convert.
  /// [output] is the destination PDF file.
  /// [progress] is an optional stream controller to report progress (0.0 to 1.0).
  Future<void> convert(File input, File output, {StreamController<double>? progress});
}
