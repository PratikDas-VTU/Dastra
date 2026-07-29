import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageConverterService {
  ImageConverterService._();

  /// Converts an image file at [inputPath] to [targetFormat] (jpg/png).
  ///
  /// Supports quality level configuration for JPG output (1-100).
  /// Accepts optional [inputBytes] for in-memory or Web file processing.
  static Future<List<int>> convert({
    required String inputPath,
    required String targetFormat,
    int quality = 90,
    Uint8List? inputBytes,
  }) async {
    Uint8List bytes;
    if (inputBytes != null) {
      bytes = inputBytes;
    } else {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw FileNotFoundException('Input file not found at path: $inputPath');
      }
      bytes = await inputFile.readAsBytes();
    }

    if (kIsWeb) {
      return _convertImpl(bytes, targetFormat, quality);
    } else {
      return Isolate.run(() => _convertImpl(bytes, targetFormat, quality));
    }
  }

  static List<int> _convertImpl(Uint8List bytes, String targetFormat, int quality) {
    // 2. Decode image using package:image (auto-detects JPG/PNG format)
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const CorruptedImageException('Could not decode or parse the image file.');
    }

    // 3. Encode image to target format
    List<int> encodedBytes;
    final normalizedFormat = targetFormat.toLowerCase();
    
    if (normalizedFormat == 'jpg' || normalizedFormat == 'jpeg') {
      encodedBytes = img.encodeJpg(image, quality: quality);
    } else if (normalizedFormat == 'png') {
      encodedBytes = img.encodePng(image);
    } else {
      throw UnsupportedFormatException('Unsupported target format: $targetFormat');
    }

    return encodedBytes;
  }
}

// ── Custom Exceptions ────────────────────────────────────────────────────────

class FileNotFoundException implements Exception {
  const FileNotFoundException(this.message);
  final String message;
  @override
  String toString() => 'FileNotFoundException: $message';
}

class CorruptedImageException implements Exception {
  const CorruptedImageException(this.message);
  final String message;
  @override
  String toString() => 'CorruptedImageException: $message';
}

class UnsupportedFormatException implements Exception {
  const UnsupportedFormatException(this.message);
  final String message;
  @override
  String toString() => 'UnsupportedFormatException: $message';
}
