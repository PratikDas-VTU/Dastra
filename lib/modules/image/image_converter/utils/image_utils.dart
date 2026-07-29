import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;

class ImageUtils {
  ImageUtils._();

  /// Reads image dimensions (width x height) directly from the file header
  /// without decoding the entire image to memory.
  ///
  /// Returns a display string e.g. "1920x1080", or "Unknown" on failure.
  static Future<String> getResolution(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return 'Unknown';

    try {
      final ext = p.extension(filePath).toLowerCase();
      if (ext == '.png') {
        return await _getPngResolution(file);
      } else if (ext == '.jpg' || ext == '.jpeg') {
        return await _getJpgResolution(file);
      }
    } catch (_) {
      // Graceful fallback to avoid crash
    }
    return 'Unknown';
  }

  /// Auto-increments filename if file already exists in target directory.
  ///
  /// E.g. "image.png" -> "image (1).png" -> "image (2).png".
  static String getUniqueOutputPath(String folder, String fileName, String targetExt) {
    final baseName = p.basenameWithoutExtension(fileName);
    final ext = targetExt.startsWith('.') ? targetExt : '.$targetExt';
    
    var outPath = p.join(folder, '$baseName$ext');
    var counter = 1;

    while (File(outPath).existsSync()) {
      outPath = p.join(folder, '$baseName ($counter)$ext');
      counter++;
    }

    return outPath;
  }

  // ── PNG Header Parser ──────────────────────────────────────────────────────

  static Future<String> _getPngResolution(File file) async {
    // Read first 24 bytes (Header + IHDR chunk)
    final handle = await file.open(mode: FileMode.read);
    try {
      final header = await handle.read(24);
      if (header.length < 24) return 'Unknown';

      // Check PNG signature [137, 80, 78, 71, 13, 10, 26, 10]
      if (header[0] != 137 || header[1] != 80 || header[2] != 78 || header[3] != 71) {
        return 'Unknown';
      }

      // Width starts at offset 16 (4 bytes, Big Endian)
      // Height starts at offset 20 (4 bytes, Big Endian)
      final data = ByteData.sublistView(header);
      final width = data.getUint32(16, Endian.big);
      final height = data.getUint32(20, Endian.big);

      return '${width}x$height';
    } finally {
      await handle.close();
    }
  }

  // ── JPG Header Parser ──────────────────────────────────────────────────────

  static Future<String> _getJpgResolution(File file) async {
    final handle = await file.open(mode: FileMode.read);
    try {
      // Read first 2 bytes to check SOI marker [0xFF, 0xD8]
      final soi = await handle.read(2);
      if (soi.length < 2 || soi[0] != 0xFF || soi[1] != 0xD8) {
        return 'Unknown';
      }

      // Loop through segments
      while (true) {
        final markerBytes = await handle.read(2);
        if (markerBytes.length < 2) return 'Unknown';

        // Segments start with 0xFF
        if (markerBytes[0] != 0xFF) return 'Unknown';

        final marker = markerBytes[1];

        // End of image or reset marker
        if (marker == 0xD9 || (marker >= 0xD0 && marker <= 0xD7)) {
          continue;
        }

        // Segment length (2 bytes, Big Endian)
        final lenBytes = await handle.read(2);
        if (lenBytes.length < 2) return 'Unknown';
        final lenData = ByteData.sublistView(lenBytes);
        final segmentLen = lenData.getUint16(0, Endian.big);

        // SOF0 (0xC0) or SOF2 (0xC2) markers contain dimensions
        if (marker == 0xC0 || marker == 0xC2) {
          // Read SOF data (excluding length bytes)
          final sofData = await handle.read(segmentLen - 2);
          if (sofData.length < 5) return 'Unknown';

          // Offset 0: Precision (1 byte)
          // Offset 1: Height (2 bytes, Big Endian)
          // Offset 3: Width (2 bytes, Big Endian)
          final view = ByteData.sublistView(sofData);
          final height = view.getUint16(1, Endian.big);
          final width = view.getUint16(3, Endian.big);

          return '${width}x$height';
        } else {
          // Skip segment data
          await handle.setPosition(await handle.position() + segmentLen - 2);
        }
      }
    } catch (_) {
      return 'Unknown';
    } finally {
      await handle.close();
    }
  }
}
