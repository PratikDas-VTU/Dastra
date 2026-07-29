import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Presets mapping to JPEG quality and PNG compression level.
enum CompressionPreset {
  lossless,
  highQuality,
  balanced,
  maxCompression,
  custom,
}

/// Resize modes for compression.
enum ResizeMode {
  original,
  scale50,
  scale75,
  custom,
}

class ImageCompressorService {
  ImageCompressorService._();

  /// Compresses an image file at [inputPath] and returns the compressed bytes.
  ///
  /// Can optionally resize the image based on [resizeMode] and custom dimensions.
  /// Uses [targetFormat] (jpg/png) for encoding.
  /// Accepts optional [inputBytes] for Web/in-memory compression tasks.
  static Future<List<int>> compress({
    required String inputPath,
    required String targetFormat,
    required CompressionPreset preset,
    int jpgQuality = 75,
    int pngLevel = 6, // 0 to 9
    ResizeMode resizeMode = ResizeMode.original,
    int? customWidth,
    int? customHeight,
    bool maintainAspectRatio = true,
    Uint8List? inputBytes,
  }) async {
    // For Web, isolates are not supported via Isolate.run, run synchronously.
    if (kIsWeb) {
      return _compressImpl(
        inputPath: inputPath,
        targetFormat: targetFormat,
        preset: preset,
        jpgQuality: jpgQuality,
        pngLevel: pngLevel,
        resizeMode: resizeMode,
        customWidth: customWidth,
        customHeight: customHeight,
        maintainAspectRatio: maintainAspectRatio,
        inputBytes: inputBytes,
      );
    }
    
    // Pass necessary arguments to Isolate to avoid capturing context unintentionally
    return Isolate.run(() => _compressImpl(
      inputPath: inputPath,
      targetFormat: targetFormat,
      preset: preset,
      jpgQuality: jpgQuality,
      pngLevel: pngLevel,
      resizeMode: resizeMode,
      customWidth: customWidth,
      customHeight: customHeight,
      maintainAspectRatio: maintainAspectRatio,
      inputBytes: inputBytes,
    ));
  }

  static Future<List<int>> _compressImpl({
    required String inputPath,
    required String targetFormat,
    required CompressionPreset preset,
    required int jpgQuality,
    required int pngLevel,
    required ResizeMode resizeMode,
    required int? customWidth,
    required int? customHeight,
    required bool maintainAspectRatio,
    required Uint8List? inputBytes,
  }) async {
    Uint8List bytes;
    if (inputBytes != null) {
      bytes = inputBytes;
    } else {
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw FileNotFoundException('File not found: $inputPath');
      }
      bytes = await inputFile.readAsBytes();
    }

    // 2. Decode image
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw const CorruptedImageException('Could not parse or decode image.');
    }

    // 3. Resolve preset values
    int finalJpgQuality = jpgQuality;
    int finalPngLevel = pngLevel;

    switch (preset) {
      case CompressionPreset.lossless:
        // True lossless is PNG
        finalPngLevel = 9;
        finalJpgQuality = 100;
        break;
      case CompressionPreset.highQuality:
        finalPngLevel = 3;
        finalJpgQuality = 90;
        break;
      case CompressionPreset.balanced:
        finalPngLevel = 6;
        finalJpgQuality = 75;
        break;
      case CompressionPreset.maxCompression:
        finalPngLevel = 9;
        finalJpgQuality = 45;
        break;
      case CompressionPreset.custom:
        // Use custom parameters passed to method
        break;
    }

    // 4. Resize if requested
    img.Image processedImage = image;
    final origW = image.width;
    final origH = image.height;

    int? targetW;
    int? targetH;

    switch (resizeMode) {
      case ResizeMode.original:
        break;
      case ResizeMode.scale50:
        targetW = (origW * 0.5).round();
        targetH = (origH * 0.5).round();
        break;
      case ResizeMode.scale75:
        targetW = (origW * 0.75).round();
        targetH = (origH * 0.75).round();
        break;
      case ResizeMode.custom:
        if (customWidth != null && customHeight != null) {
          if (maintainAspectRatio) {
            final ratio = origW / origH;
            if (customWidth / customHeight > ratio) {
              targetH = customHeight;
              targetW = (customHeight * ratio).round();
            } else {
              targetW = customWidth;
              targetH = (customWidth / ratio).round();
            }
          } else {
            targetW = customWidth;
            targetH = customHeight;
          }
        } else if (customWidth != null) {
          targetW = customWidth;
          targetH = (customWidth * (origH / origW)).round();
        } else if (customHeight != null) {
          targetH = customHeight;
          targetW = (customHeight * (origW / origH)).round();
        }
        break;
    }

    if (targetW != null || targetH != null) {
      processedImage = img.copyResize(
        image,
        width: targetW,
        height: targetH,
      );
    }

    // 5. Encode to target format
    List<int> encodedBytes;
    final normExt = targetFormat.replaceAll('.', '').toLowerCase();

    if (normExt == 'jpg' || normExt == 'jpeg') {
      encodedBytes = img.encodeJpg(processedImage, quality: finalJpgQuality);
    } else if (normExt == 'png') {
      encodedBytes = img.encodePng(processedImage, level: finalPngLevel);
    } else {
      throw UnsupportedFormatException('Unsupported extension: $targetFormat');
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
