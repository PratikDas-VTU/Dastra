import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../shared/model/document_job.dart';
import '../../shared/model/document_progress_state.dart';
import '../../shared/model/conversion_result_data.dart';
import '../../shared/model/output_configuration.dart';
import '../../shared/services/pdf_core_service.dart';
import '../../shared/services/pdf_merge_service.dart';
import '../../shared/services/output_service.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';

class PdfMergeController extends ChangeNotifier with DocumentProgressState {
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;

  final List<DocumentJob> _jobs = [];
  
  List<DocumentJob> get jobs => _jobs;
  bool get hasJobs => _jobs.isNotEmpty;
  bool get canMerge => _jobs.length > 1 && !isProcessing;
  
  bool get isMerging => isProcessing;
  double get overallProgress => progress;

  int get totalOriginalSize => _jobs.fold(0, (sum, job) => sum + job.fileSize);
  int get totalPages => _jobs.fold(0, (sum, job) => sum + (job.pageCount ?? 0));

  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  PdfMergeController(this._outputService, this._workspaceRepository);

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true, 
    );

    if (result != null && result.files.isNotEmpty) {
      await _addPickerFiles(result.files);
    }
  }

  Future<void> _addPickerFiles(List<PlatformFile> files) async {
    for (final file in files) {
      final path = kIsWeb ? '' : (file.path ?? '');
      
      if (_jobs.any((j) => (path.isNotEmpty && j.filePath == path) || j.fileName == file.name)) {
        continue;
      }

      final name = file.name;
      final size = file.size;

      Uint8List? rawBytes = file.bytes;
      if (!kIsWeb && rawBytes == null && path.isNotEmpty) {
        rawBytes = await File(path).readAsBytes();
      }

      int pageCount = 0;
      if (rawBytes != null) {
        pageCount = await PdfCoreService.getPageCount(rawBytes);
      }

      _jobs.add(
        DocumentJob(
          id: DateTime.now().microsecondsSinceEpoch.toString() + name,
          filePath: path,
          fileName: name,
          fileSize: size,
          pageCount: pageCount,
          bytes: rawBytes,
        ),
      );
    }
    
    if (_jobs.isNotEmpty && _outputConfig == null) {
      final defaultFolder = await _outputService.getDefaultOutputFolder();
      _outputConfig = OutputConfiguration(
        filename: 'merged_document',
        folderPath: defaultFolder,
      );
    }
    
    notifyListeners();
  }

  void removeJob(String id) {
    _jobs.removeWhere((j) => j.id == id);
    if (_jobs.isEmpty) {
      _outputConfig = null;
      resetProgress();
    }
    notifyListeners();
  }

  void reorderJobs(int oldIndex, int newIndex) {
    final DocumentJob item = _jobs.removeAt(oldIndex);
    _jobs.insert(newIndex, item);
    notifyListeners();
  }

  void clearJobs() {
    _jobs.clear();
    _outputConfig = null;
    resetProgress();
  }

  void updateOutputConfig(OutputConfiguration config) {
    _outputConfig = config;
    notifyListeners();
  }

  Future<void> pickOutputFolder() async {
    if (_outputConfig == null) return;
    final folder = await _outputService.pickFolder(_outputConfig!.folderPath);
    if (folder != null) {
      _outputConfig = _outputConfig!.copyWith(folderPath: folder);
      notifyListeners();
    }
  }

  Future<void> mergePdfs() async {
    if (!canMerge || _outputConfig == null) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Offline merge is not supported on Web.');
      return;
    }

    setProcessingState(isProcessing: true, progress: 0.1, statusMessage: 'Reading documents...');

    final startTime = DateTime.now();

    try {
      final List<Uint8List> inputBytes = [];
      for (final job in _jobs) {
        if (job.bytes != null) {
          inputBytes.add(job.bytes!);
        } else if (job.filePath.isNotEmpty) {
          final fileBytes = await File(job.filePath).readAsBytes();
          inputBytes.add(fileBytes);
        }
      }

      if (inputBytes.length < 2) {
        throw Exception("Not enough valid documents to merge.");
      }

      updateProgress(0.4, 'Merging pages in background...');

      final mergedBytes = await PdfMergeService.mergePdfs(inputBytes);

      updateProgress(0.8, 'Saving merged document...');

      final outFileName = '${_outputConfig!.filename}.pdf';
      final requestedOutPath = p.join(_outputConfig!.folderPath, outFileName);

      final stopTime = DateTime.now();
      final durationMs = stopTime.difference(startTime).inMilliseconds;
      
      final savedFile = await _outputService.saveFile(requestedOutPath, mergedBytes, _outputConfig!);
      
      final resultData = ConversionResultData(
        outputFilename: p.basename(savedFile.path),
        outputPath: savedFile.absolute.path,
        outputFolder: savedFile.parent.absolute.path,
        processingTimeMs: durationMs,
        statistics: [
          ConversionStatistic('Merged Files', '${_jobs.length} files'),
          ConversionStatistic('Total Pages', '$totalPages pages'),
          ConversionStatistic('Output Size', '${(mergedBytes.length / 1024).toStringAsFixed(1)} KB'),
          ConversionStatistic('Processing Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
        ],
      );
      
      // Record in Workspace
      await _workspaceRepository.insertRecord(WorkspaceRecord(
        id: const Uuid().v4(),
        toolId: 'pdf_merge',
        toolName: 'Merge PDF',
        inputPath: 'Multiple Files (${_jobs.length})',
        outputPath: savedFile.absolute.path,
        outputFolder: savedFile.parent.absolute.path,
        outputExtension: '.pdf',
        inputSize: totalOriginalSize,
        outputSize: mergedBytes.length,
        processingTime: durationMs,
        createdAt: DateTime.now(),
        status: 'success',
      ));
      
      setSuccessState(resultData);
    } catch (e) {
      setProcessingState(isProcessing: false, progress: 0.0, statusMessage: 'Merge failed: $e');
    }
  }
}
