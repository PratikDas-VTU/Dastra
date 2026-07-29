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
import '../model/conversion_job.dart';
import '../services/image_converter_service.dart';
import '../utils/image_utils.dart';

class ImageConverterController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  List<ConversionJob> _jobs = [];
  String? _customOutputFolder;
  String _targetFormat = 'png'; // Default target format
  int _quality = 90; // Default JPG quality
  bool _isConverting = false;
  double _overallProgress = 0.0;

  // ── Constructor ────────────────────────────────────────────────────────────

  ImageConverterController() {
    debugPrint('=============================================');
    debugPrint('[TRACE] IMAGE CONVERTER CONTROLLER CREATED!');
    debugPrint('=============================================');
    _initDefaultOutputFolder();
  }

  // ── Public Getters ─────────────────────────────────────────────────────────

  List<ConversionJob> get jobs => _jobs;
  String? get customOutputFolder => _customOutputFolder;
  String get targetFormat => _targetFormat;
  int get quality => _quality;
  bool get isConverting => _isConverting;
  double get overallProgress => _overallProgress;

  /// Returns true when at least one job exists.
  bool get hasJobs => _jobs.isNotEmpty;

  /// Returns count of successfully completed jobs.
  int get completedCount =>
      _jobs.where((j) => j.status == ConversionStatus.success).length;

  /// Returns count of failed jobs.
  int get failedCount =>
      _jobs.where((j) => j.status == ConversionStatus.failed).length;

  /// Returns true when all jobs are completed (success or failed).
  bool get isAllCompleted =>
      _jobs.isNotEmpty && _jobs.every((j) => j.status == ConversionStatus.success || j.status == ConversionStatus.failed);

  // ── Public Actions ─────────────────────────────────────────────────────────

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

  /// Appends lists of file paths to jobs list (used by drag-drop).
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

  /// Appends PlatformFile objects (supports web and native)
  Future<void> addPickerFiles(List<PlatformFile> files) async {
    for (final file in files) {
      // FIX: Accessing file.path on Web throws an UnsupportedError in file_picker > 8.0
      final path = kIsWeb ? '' : (file.path ?? '');
      
      // Avoid duplicate paths/names
      if (_jobs.any((j) => (path.isNotEmpty && j.filePath == path) || j.fileName == file.name)) {
        continue;
      }

      final name = file.name;
      final size = file.size;
      final originalFormat = p.extension(name).replaceAll('.', '').toLowerCase();
      
      // Auto-set inverse target format
      final jobTargetFormat = (originalFormat == 'png') ? 'jpg' : 'png';

      // Parse resolution
      String resolution = 'Unknown';
      if (kIsWeb && file.bytes != null) {
        resolution = _getResolutionFromBytes(file.bytes!);
      } else if (path.isNotEmpty) {
        resolution = await ImageUtils.getResolution(path);
      }

      _jobs.add(
        ConversionJob(
          id: DateTime.now().microsecondsSinceEpoch.toString() + name,
          filePath: path,
          fileName: name,
          fileSize: size,
          originalFormat: originalFormat,
          targetFormat: jobTargetFormat,
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

  /// Removes a job from the queue.
  void removeJob(String id) {
    _jobs.removeWhere((j) => j.id == id);
    if (_jobs.isEmpty) {
      _overallProgress = 0.0;
    }
    notifyListeners();
  }

  /// Clears all jobs.
  void clearJobs() {
    _jobs.clear();
    _overallProgress = 0.0;
    _isConverting = false;
    notifyListeners();
  }

  /// Changes the global target format and updates all pending/idle jobs.
  void setTargetFormat(String format) {
    if (_targetFormat == format) return;
    _targetFormat = format;
    _jobs = _jobs.map((job) {
      if (job.status == ConversionStatus.pending) {
        return job.copyWith(targetFormat: format);
      }
      return job;
    }).toList();
    notifyListeners();
  }

  /// Sets individual job target format.
  void setJobTargetFormat(String id, String format) {
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jobs[index] = _jobs[index].copyWith(targetFormat: format);
      notifyListeners();
    }
  }

  /// Updates JPG output compression quality (1-100).
  void setQuality(int value) {
    final clamped = value.clamp(1, 100);
    if (_quality == clamped) return;
    _quality = clamped;
    notifyListeners();
  }

  /// Opens directory picker to select custom output folder (Desktop only).
  Future<void> selectOutputFolder() async {
    final folder = await FilePicker.getDirectoryPath();
    if (folder != null) {
      _customOutputFolder = folder;
      notifyListeners();
    }
  }

  /// Resets custom output folder selection back to system defaults.
  void resetOutputFolder() {
    _customOutputFolder = null;
    notifyListeners();
  }

  /// Converts all pending jobs in sequence (batch).
  Future<void> startConversion() async {
    if (_jobs.isEmpty || _isConverting) return;

    _isConverting = true;
    _overallProgress = 0.0;
    notifyListeners();

    final outputDir = kIsWeb ? '' : await getEffectiveOutputDir();
    final startTime = DateTime.now();

    for (int i = 0; i < _jobs.length; i++) {
      var job = _jobs[i];
      if (job.status == ConversionStatus.success) continue;

      _jobs[i] = job.copyWith(status: ConversionStatus.processing, progress: 0.1);
      notifyListeners();

      try {
        final encodedBytes = await ImageConverterService.convert(
          inputPath: job.filePath,
          targetFormat: job.targetFormat,
          quality: _quality,
          inputBytes: job.bytes,
        );

        String? uniqueOutPath;
        if (kIsWeb) {
          final base64 = base64Encode(encodedBytes);
          final filename = '${p.basenameWithoutExtension(job.fileName)}.${job.targetFormat.toLowerCase()}';
          downloadBase64Web(base64, filename, job.targetFormat.toLowerCase());
          uniqueOutPath = '${job.fileName}.${job.targetFormat}';
        } else {
          final config = OutputConfiguration(
            filename: '${p.basenameWithoutExtension(job.fileName)}.${job.targetFormat.toLowerCase()}',
            folderPath: outputDir,
            duplicateStrategy: DuplicateHandlingStrategy.autoRename,
          );
          final requestedOutPath = p.join(outputDir, config.filename);
          final outputFile = await sl<OutputService>().saveFile(requestedOutPath, Uint8List.fromList(encodedBytes), config);
          uniqueOutPath = outputFile.path;
        }

        _jobs[i] = _jobs[i].copyWith(
          status: ConversionStatus.success,
          progress: 1.0,
          outputPath: uniqueOutPath,
          bytes: Uint8List.fromList(encodedBytes),
        );
      } catch (e) {
        _jobs[i] = _jobs[i].copyWith(
          status: ConversionStatus.failed,
          progress: 1.0,
          error: e.toString(),
        );
      }

      // Update overall progress
      _overallProgress = (i + 1) / _jobs.length;
      notifyListeners();
    }

    final stopTime = DateTime.now();
    final durationMs = stopTime.difference(startTime).inMilliseconds;

    // Track workspace record
    final successJobs = _jobs.where((j) => j.status == ConversionStatus.success).toList();
    if (successJobs.isNotEmpty && !kIsWeb) {
      final totalOriginal = successJobs.fold<int>(0, (sum, j) => sum + j.fileSize);
      final totalConverted = successJobs.fold<int>(0, (sum, j) => sum + (j.bytes?.length ?? 0));
      final outputPath = successJobs.length == 1 ? successJobs.first.outputPath! : outputDir;
      
      try {
        await sl<WorkspaceRepository>().insertRecord(WorkspaceRecord(
          id: const Uuid().v4(),
          toolId: 'image_converter',
          toolName: 'Image Converter',
          inputPath: successJobs.length == 1 ? successJobs.first.filePath : 'Multiple Images (${successJobs.length})',
          outputPath: outputPath,
          outputFolder: outputDir,
          outputExtension: successJobs.length == 1 ? '.${successJobs.first.targetFormat}' : '',
          inputSize: totalOriginal,
          outputSize: totalConverted,
          processingTime: durationMs,
          createdAt: DateTime.now(),
          status: 'success',
        ));
      } catch (e) {
        debugPrint('Failed to log workspace record: $e');
      }
    }

    _isConverting = false;
    notifyListeners();
  }

  /// Retrieves the directory path where output files will be saved.
  Future<String> getEffectiveOutputDir() async {
    if (kIsWeb) return '';
    if (_customOutputFolder != null) {
      return _customOutputFolder!;
    }
    final outputService = sl<OutputService>();
    return await outputService.getDefaultOutputFolder();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  Future<void> _initDefaultOutputFolder() async {
    // Read early default paths for UI reference
  }
}
