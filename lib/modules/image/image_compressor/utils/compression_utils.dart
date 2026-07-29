import '../../image_converter/utils/image_utils.dart';

class CompressionUtils {
  CompressionUtils._();

  /// Formats byte sizes to human-readable strings.
  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }

  /// Formats ratio decimal e.g. 0.354 -> "35.4%".
  static String formatRatio(double ratio) {
    final pct = ratio * 100;
    return '${pct.toStringAsFixed(1)}%';
  }

  /// Extracts image dimensions from file header. Reuses [ImageUtils].
  static Future<String> getResolution(String filePath) async {
    return ImageUtils.getResolution(filePath);
  }

  /// Generates a unique output name. Reuses [ImageUtils].
  static String getUniqueOutputPath(String folder, String fileName, String targetExt) {
    return ImageUtils.getUniqueOutputPath(folder, fileName, targetExt);
  }
}
