import 'dart:async';
import 'dart:io';
import '../../../../core/engine/contracts/abstract_engine.dart';

abstract class PdfToWordEngine extends DocumentConversionEngine {
  Future<void> convertPdfToWord(File input, File output, {StreamController<double>? progress});
}
