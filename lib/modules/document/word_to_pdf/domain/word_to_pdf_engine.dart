import 'dart:async';
import 'dart:io';
import '../../../../core/engine/contracts/abstract_engine.dart';

abstract class WordToPdfEngine extends AbstractEngine {
  /// Converts a DOCX/DOC file to a PDF file.
  /// [input] is the Word file to convert.
  /// [output] is the destination PDF file.
  /// [progress] is an optional stream controller to report progress (0.0 to 1.0).
  Future<void> convert(File input, File output, {StreamController<double>? progress});
}
