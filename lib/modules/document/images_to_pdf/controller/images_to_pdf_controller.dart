import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../shared/model/document_job.dart';
import '../../shared/model/document_progress_state.dart';
import '../../shared/model/conversion_result_data.dart';
import '../../shared/model/output_configuration.dart';
import '../../shared/services/images_to_pdf_service.dart';
import '../../shared/services/output_service.dart';
import '../model/images_to_pdf_config.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';
import 'package:path/path.dart' as p;

class ImagesToPdfController extends ChangeNotifier with DocumentProgressState {
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;

  final List<DocumentJob> _jobs = [];
  List<DocumentJob> get jobs => _jobs;

  ImagesToPdfConfig _config = const ImagesToPdfConfig();
  ImagesToPdfConfig get config => _config;

  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  bool get canGenerate => _jobs.isNotEmpty && !isProcessing;

  ImagesToPdfController(this._outputService, this._workspaceRepository);

  void updateConfig(ImagesToPdfConfig newConfig) {
    _config = newConfig;
    notifyListeners();
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

  void reorderImages(int oldIndex, int newIndex) {
    final item = _jobs.removeAt(oldIndex);
    _jobs.insert(newIndex, item);
    notifyListeners();
  }

  void removeImage(String id) {
    _jobs.removeWhere((job) => job.id == id);
    if (_jobs.isEmpty) {
      _outputConfig = null;
      resetProgress();
    }
    notifyListeners();
  }

  void clearAll() {
    _jobs.clear();
    _outputConfig = null;
    resetProgress();
  }

  Future<void> pickFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        updateProgress(0.0, 'Loading images...');
        
        for (final file in result.files) {
          if (file.bytes != null) {
            final job = DocumentJob(
              id: DateTime.now().microsecondsSinceEpoch.toString() + file.name,
              fileName: file.name,
              filePath: kIsWeb ? '' : (file.path ?? ''),
              fileSize: file.size,
              bytes: file.bytes!,
            );
            _jobs.add(job);
          }
        }
        
        if (_jobs.isNotEmpty && _outputConfig == null) {
          final defaultFolder = await _outputService.getDefaultOutputFolder();
          _outputConfig = OutputConfiguration(
            filename: 'images_to_pdf',
            folderPath: defaultFolder,
          );
        }
        
        resetProgress();
      }
    } catch (e) {
      setProcessingState(isProcessing: false, statusMessage: 'Error selecting files: $e');
    }
  }

  Future<void> generatePdf() async {
    if (!canGenerate || _outputConfig == null) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Offline generation is not supported on Web.');
      return;
    }

    try {
      setProcessingState(isProcessing: true, progress: 0.2, statusMessage: 'Generating PDF...');
      
      final startTime = DateTime.now();

      final List<Uint8List> images = _jobs.map((j) => j.bytes!).toList();
      int totalOriginalSize = _jobs.fold(0, (sum, j) => sum + j.fileSize);
      
      updateProgress(0.4);
      
      final String outName = '${_outputConfig!.filename}.pdf';

      final result = await ImagesToPdfService.imagesToPdf(images, _config, outName);

      if (!result.isSuccess) {
        throw Exception(result.error ?? 'Unknown error occurred.');
      }

      updateProgress(0.8, 'Saving PDF...');
        
      final fileOut = result.files.first;
      final requestedOutPath = p.join(_outputConfig!.folderPath, outName);
      
      final savedFile = await _outputService.saveFile(requestedOutPath, fileOut.bytes, _outputConfig!);
      
      final stopTime = DateTime.now();
      final durationMs = stopTime.difference(startTime).inMilliseconds;
      
      final resultData = ConversionResultData(
        outputFilename: p.basename(savedFile.path),
        outputPath: savedFile.absolute.path,
        outputFolder: savedFile.parent.absolute.path,
        processingTimeMs: durationMs,
        statistics: [
          ConversionStatistic('Images Included', '${_jobs.length} images'),
          ConversionStatistic('Original Size', '${(totalOriginalSize / 1024).toStringAsFixed(1)} KB'),
          ConversionStatistic('Output Size', '${(fileOut.bytes.length / 1024).toStringAsFixed(1)} KB'),
          ConversionStatistic('Processing Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
        ],
      );
      
      // Record in Workspace
      await _workspaceRepository.insertRecord(WorkspaceRecord(
        id: const Uuid().v4(),
        toolId: 'images_to_pdf',
        toolName: 'Images to PDF',
        inputPath: 'Multiple Images (${_jobs.length})',
        outputPath: savedFile.absolute.path,
        outputFolder: savedFile.parent.absolute.path,
        outputExtension: '.pdf',
        inputSize: totalOriginalSize,
        outputSize: fileOut.bytes.length,
        processingTime: durationMs,
        createdAt: DateTime.now(),
        status: 'success',
      ));
      
      setSuccessState(resultData);

    } catch (e) {
      setProcessingState(isProcessing: false, statusMessage: 'Error: $e');
    }
  }
}
