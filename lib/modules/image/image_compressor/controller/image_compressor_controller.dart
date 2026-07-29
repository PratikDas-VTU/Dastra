import 'dart:io';
import 'dart:convert';
import '../../../../core/utils/web_download.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../../../core/di/service_locator.dart';
import '../../../document/shared/services/output_service.dart';
import '../../../document/shared/model/output_configuration.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';
import '../model/compression_job.dart';
import '../services/image_compressor_service.dart';
import '../utils/compression_utils.dart';

class ImageCompressorController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  final List<CompressionJob> _jobs = [];
  CompressionPreset _preset = CompressionPreset.balanced;
  int _jpgQuality = 75;
  int _pngLevel = 6;
  ResizeMode _resizeMode = ResizeMode.original;
  int? _customWidth;
  int? _customHeight;
  bool _maintainAspectRatio = true;
  String? _customOutputFolder;
  bool _isCompressing = false;
  double _overallProgress = 0.0;
  Duration _processingDuration = Duration.zero;

  // ── Public Getters ─────────────────────────────────────────────────────────

  List<CompressionJob> get jobs => _jobs;
  CompressionPreset get preset => _preset;
  int get jpgQuality => _jpgQuality;
  int get pngLevel => _pngLevel;
  ResizeMode get resizeMode => _resizeMode;
  int? get customWidth => _customWidth;
  int? get customHeight => _customHeight;
  bool get maintainAspectRatio => _maintainAspectRatio;
  String? get customOutputFolder => _customOutputFolder;
  bool get isCompressing => _isCompressing;
  double get overallProgress => _overallProgress;
  Duration get processingDuration => _processingDuration;

  bool get hasJobs => _jobs.isNotEmpty;

  int get completedCount =>
      _jobs.where((j) => j.status == CompressionStatus.success).length;

  int get failedCount =>
      _jobs.where((j) => j.status == CompressionStatus.failed).length;

  bool get isAllCompleted =>
      _jobs.isNotEmpty && _jobs.every((j) => j.status == CompressionStatus.success || j.status == CompressionStatus.failed);

  // ── Summary Calculations ───────────────────────────────────────────────────

  int get totalOriginalSize => _jobs
      .where((j) => j.status == CompressionStatus.success)
      .map((j) => j.fileSize)
      .fold(0, (a, b) => a + b);

  int get totalCompressedSize => _jobs
      .where((j) => j.status == CompressionStatus.success)
      .map((j) => j.compressedSize ?? 0)
      .fold(0, (a, b) => a + b);

  int get totalSpaceSaved {
    final diff = totalOriginalSize - totalCompressedSize;
    return diff > 0 ? diff : 0;
  }

  double get averageCompressionRatio {
    final successJobs = _jobs.where((j) => j.status == CompressionStatus.success && j.fileSize > 0);
    if (successJobs.isEmpty) return 0.0;
    final totalRatio = successJobs.map((j) => j.compressionRatio).fold(0.0, (a, b) => a + b);
    return totalRatio / successJobs.length;
  }

  // ── Public Actions ─────────────────────────────────────────────────────────

  /// Picks files from disk and appends to the queue.
  Future<void> pickImages() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: true, // Required for Web to get bytes
    );

    if (result != null && result.files.isNotEmpty) {
      await addPickerFiles(result.files);
    }
  }

  /// Appends image paths to the queue (used by drag-drop).
  Future<void> addImages(List<String> paths) async {
    final platformFiles = <PlatformFile>[];
    for (final path in paths) {
      final file = File(path);
      if (!await file.exists()) continue;
      final bytes = await file.readAsBytes();
      platformFiles.add(PlatformFile(
        path: path,
        name: p.basename(path),
        size: await file.length(),
        bytes: bytes,
      ));
    }
    await addPickerFiles(platformFiles);
  }

  /// Appends PlatformFile objects.
  Future<void> addPickerFiles(List<PlatformFile> files) async {
    for (final file in files) {
      // FIX: Accessing file.path on Web throws an UnsupportedError in file_picker > 8.0
      final path = kIsWeb ? '' : (file.path ?? '');
      
      if (_jobs.any((j) => (path.isNotEmpty && j.filePath == path) || j.fileName == file.name)) {
        continue;
      }

      final name = file.name;
      final size = file.size;
      final originalFormat = p.extension(name).replaceAll('.', '').toLowerCase();

      // Read resolution using CompressionUtils
      String resolution = 'Unknown';
      if (kIsWeb && file.bytes != null) {
        resolution = _getResolutionFromBytes(file.bytes!);
      } else if (path.isNotEmpty) {
        resolution = await CompressionUtils.getResolution(path);
      }

      _jobs.add(
        CompressionJob(
          id: DateTime.now().microsecondsSinceEpoch.toString() + name,
          filePath: path,
          fileName: name,
          fileSize: size,
          originalFormat: originalFormat,
          targetFormat: originalFormat,
          resolution: resolution,
          bytes: file.bytes,
        ),
      );
    }
    notifyListeners();
  }

  static String _getResolutionFromBytes(Uint8List bytes) {
    try {
      if (bytes.length >= 24 &&
          bytes[0] == 137 &&
          bytes[1] == 80 &&
          bytes[2] == 78 &&
          bytes[3] == 71) {
        // PNG
        final data = ByteData.sublistView(bytes);
        final width = data.getUint32(16, Endian.big);
        final height = data.getUint32(20, Endian.big);
        return '${width}x$height';
      } else if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
        // JPG
        var offset = 2;
        while (offset < bytes.length) {
          if (bytes[offset] != 0xFF) return 'Unknown';
          final marker = bytes[offset + 1];
          if (marker == 0xD9 || (marker >= 0xD0 && marker <= 0xD7)) {
            offset += 2;
            continue;
          }
          final segmentLen = ByteData.sublistView(bytes, offset + 2, offset + 4).getUint16(0, Endian.big);
          if (marker == 0xC0 || marker == 0xC2) {
            final view = ByteData.sublistView(bytes, offset + 4, offset + 4 + segmentLen - 2);
            final height = view.getUint16(1, Endian.big);
            final width = view.getUint16(3, Endian.big);
            return '${width}x$height';
          } else {
            offset += 2 + segmentLen;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to extract image resolution: $e');
    }
    return 'Unknown';
  }

  /// Removes a single job.
  void removeJob(String id) {
    _jobs.removeWhere((j) => j.id == id);
    if (_jobs.isEmpty) {
      _overallProgress = 0.0;
    }
    notifyListeners();
  }

  /// Resets all state.
  void clearJobs() {
    _jobs.clear();
    _overallProgress = 0.0;
    _isCompressing = false;
    _processingDuration = Duration.zero;
    notifyListeners();
  }

  /// Updates compression preset and configures associated default quality levels.
  void setPreset(CompressionPreset newPreset) {
    if (_preset == newPreset) return;
    _preset = newPreset;

    switch (newPreset) {
      case CompressionPreset.lossless:
        _jpgQuality = 100;
        _pngLevel = 9;
        break;
      case CompressionPreset.highQuality:
        _jpgQuality = 90;
        _pngLevel = 3;
        break;
      case CompressionPreset.balanced:
        _jpgQuality = 75;
        _pngLevel = 6;
        break;
      case CompressionPreset.maxCompression:
        _jpgQuality = 45;
        _pngLevel = 9;
        break;
      case CompressionPreset.custom:
        break;
    }
    notifyListeners();
  }

  /// Updates quality slider for JPEGs.
  void setJpgQuality(int value) {
    final clamped = value.clamp(1, 100);
    if (_jpgQuality == clamped) return;
    _jpgQuality = clamped;
    _preset = CompressionPreset.custom;
    notifyListeners();
  }

  /// Updates PNG level.
  void setPngLevel(int value) {
    final clamped = value.clamp(0, 9);
    if (_pngLevel == clamped) return;
    _pngLevel = clamped;
    _preset = CompressionPreset.custom;
    notifyListeners();
  }

  /// Updates resize mode.
  void setResizeMode(ResizeMode mode) {
    if (_resizeMode == mode) return;
    _resizeMode = mode;
    notifyListeners();
  }

  /// Sets custom resolution dimension bounds.
  void setCustomWidth(int? width) {
    _customWidth = width;
    notifyListeners();
  }

  void setCustomHeight(int? height) {
    _customHeight = height;
    notifyListeners();
  }

  /// Configures whether to maintain the original aspect ratio when custom resizing.
  void setMaintainAspectRatio(bool value) {
    if (_maintainAspectRatio == value) return;
    _maintainAspectRatio = value;
    notifyListeners();
  }

  /// Picker to select output folder.
  Future<void> selectOutputFolder() async {
    final folder = await FilePicker.getDirectoryPath();
    if (folder != null) {
      _customOutputFolder = folder;
      notifyListeners();
    }
  }

  /// Resets folder output destination.
  void resetOutputFolder() {
    _customOutputFolder = null;
    notifyListeners();
  }

  /// Starts compression processing.
  Future<void> startCompression() async {
    if (_jobs.isEmpty || _isCompressing) return;

    _isCompressing = true;
    _overallProgress = 0.0;
    _processingDuration = Duration.zero;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    final outputDir = kIsWeb ? '' : await getEffectiveOutputDir();

    for (int i = 0; i < _jobs.length; i++) {
      var job = _jobs[i];
      if (job.status == CompressionStatus.success) continue;

      _jobs[i] = job.copyWith(status: CompressionStatus.processing, progress: 0.1);
      notifyListeners();

      try {
        final encodedBytes = await ImageCompressorService.compress(
          inputPath: job.filePath,
          targetFormat: job.targetFormat,
          preset: _preset,
          jpgQuality: _jpgQuality,
          pngLevel: _pngLevel,
          resizeMode: _resizeMode,
          customWidth: _customWidth,
          customHeight: _customHeight,
          maintainAspectRatio: _maintainAspectRatio,
          inputBytes: job.bytes,
        );

        String? uniqueOutPath;
        if (kIsWeb) {
          final base64 = base64Encode(encodedBytes);
          final filename = 'compressed_${p.basenameWithoutExtension(job.fileName)}.${job.targetFormat.toLowerCase()}';
          downloadBase64Web(base64, filename, job.targetFormat.toLowerCase());
          uniqueOutPath = 'compressed_${job.fileName}.${job.targetFormat}';
        } else {
          final config = OutputConfiguration(
            filename: '${p.basenameWithoutExtension(job.fileName)}_compressed.${job.targetFormat.toLowerCase()}',
            folderPath: outputDir,
            duplicateStrategy: DuplicateHandlingStrategy.autoRename,
          );
          final requestedOutPath = p.join(outputDir, config.filename);
          final outputFile = await sl<OutputService>().saveFile(requestedOutPath, Uint8List.fromList(encodedBytes), config);
          uniqueOutPath = outputFile.path;
        }

        _jobs[i] = _jobs[i].copyWith(
          status: CompressionStatus.success,
          progress: 1.0,
          outputPath: uniqueOutPath,
          compressedSize: encodedBytes.length,
          bytes: Uint8List.fromList(encodedBytes),
        );
      } catch (e) {
        _jobs[i] = _jobs[i].copyWith(
          status: CompressionStatus.failed,
          progress: 1.0,
          error: e.toString(),
        );
      }

      _overallProgress = (i + 1) / _jobs.length;
      notifyListeners();
    }

    stopwatch.stop();
    _processingDuration = stopwatch.elapsed;

    // Track workspace record
    final successJobs = _jobs.where((j) => j.status == CompressionStatus.success).toList();
    if (successJobs.isNotEmpty && !kIsWeb) {
      final totalOriginal = successJobs.fold<int>(0, (sum, j) => sum + j.fileSize);
      final totalCompressed = successJobs.fold<int>(0, (sum, j) => sum + (j.compressedSize ?? 0));
      final outputPath = successJobs.length == 1 ? successJobs.first.outputPath! : outputDir;
      
      try {
        await sl<WorkspaceRepository>().insertRecord(WorkspaceRecord(
          id: const Uuid().v4(),
          toolId: 'image_compressor',
          toolName: 'Image Compressor',
          inputPath: successJobs.length == 1 ? successJobs.first.filePath : 'Multiple Images (${successJobs.length})',
          outputPath: outputPath,
          outputFolder: outputDir,
          outputExtension: successJobs.length == 1 ? '.${successJobs.first.targetFormat}' : '',
          inputSize: totalOriginal,
          outputSize: totalCompressed,
          processingTime: stopwatch.elapsedMilliseconds,
          createdAt: DateTime.now(),
          status: 'success',
        ));
      } catch (e) {
        debugPrint('Failed to log workspace record: $e');
      }
    }

    _isCompressing = false;
    notifyListeners();
  }

  /// Retrieves target destination directory path.
  Future<String> getEffectiveOutputDir() async {
    if (kIsWeb) return '';
    if (_customOutputFolder != null) {
      return _customOutputFolder!;
    }
    final outputService = sl<OutputService>();
    return await outputService.getDefaultOutputFolder();
  }
}
