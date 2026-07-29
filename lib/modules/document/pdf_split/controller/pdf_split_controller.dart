import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../shared/model/document_job.dart';
import '../../shared/model/document_progress_state.dart';
import '../../shared/model/conversion_result_data.dart';
import '../../shared/model/output_configuration.dart';
import '../../shared/services/pdf_core_service.dart';
import '../../shared/services/pdf_split_service.dart';
import '../../shared/services/output_service.dart';
import '../../shared/model/split_config.dart';
import '../../../../core/utils/zip_utils.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';
import 'package:path/path.dart' as p;

enum SplitMode {
  extractAll,
  customRange,
  fixedInterval,
}

class PdfSplitController extends ChangeNotifier with DocumentProgressState {
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;

  DocumentJob? _activeJob;
  DocumentJob? get activeJob => _activeJob;

  SplitMode _splitMode = SplitMode.extractAll;
  SplitMode get splitMode => _splitMode;

  String _customRange = '';
  String get customRange => _customRange;

  String _interval = '2';
  String get interval => _interval;
  
  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  PdfSplitController(this._outputService, this._workspaceRepository);

  void setSplitMode(SplitMode mode) {
    _splitMode = mode;
    notifyListeners();
  }

  void setCustomRange(String range) {
    _customRange = range;
    notifyListeners();
  }

  void setInterval(String val) {
    _interval = val;
    notifyListeners();
  }

  bool get canSplit {
    if (_activeJob == null || isProcessing) return false;
    
    if (_splitMode == SplitMode.customRange) {
      if (_customRange.trim().isEmpty) return false;
      final config = CustomRangeSplitConfig(rangeString: _customRange);
      final groups = config.resolve(_activeJob!.pageCount!);
      return groups.isNotEmpty;
    }
    
    if (_splitMode == SplitMode.fixedInterval) {
      final val = int.tryParse(_interval);
      return val != null && val > 0 && val <= _activeJob!.pageCount!;
    }
    
    return true; 
  }

  int get estimatedOutputFiles {
    if (_activeJob == null) return 0;
    
    try {
      SplitConfig config;
      switch (_splitMode) {
        case SplitMode.extractAll:
          config = const ExtractAllSplitConfig();
          break;
        case SplitMode.customRange:
          if (_customRange.trim().isEmpty) return 0;
          config = CustomRangeSplitConfig(rangeString: _customRange);
          break;
        case SplitMode.fixedInterval:
          final val = int.tryParse(_interval);
          if (val == null || val <= 0) return 0;
          config = IntervalSplitConfig(pagesPerSplit: val);
          break;
      }
      return config.resolve(_activeJob!.pageCount!).length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> pickFile() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          updateProgress(0.0, 'Reading PDF...');
          
          final pageCount = await PdfCoreService.getPageCount(file.bytes!);
          
          _activeJob = DocumentJob(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: file.name,
            filePath: kIsWeb ? '' : (file.path ?? ''),
            fileSize: file.size,
            bytes: file.bytes!,
            pageCount: pageCount,
          );
          
          final defaultFolder = await _outputService.getDefaultOutputFolder();
          final baseName = p.basenameWithoutExtension(file.name);
          _outputConfig = OutputConfiguration(
            filename: '${baseName}_split',
            folderPath: defaultFolder,
          );
          
          resetProgress();
        }
      }
    } catch (e) {
      setProcessingState(isProcessing: false, statusMessage: 'Error selecting file: $e');
    }
  }

  void removeFile() {
    _activeJob = null;
    _outputConfig = null;
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

  Future<void> splitPdf() async {
    if (!canSplit || _activeJob == null || _outputConfig == null) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Offline split is not supported on Web.');
      return;
    }

    try {
      setProcessingState(isProcessing: true, progress: 0.2, statusMessage: 'Preparing to split...');
      
      final startTime = DateTime.now();

      SplitConfig config;
      switch (_splitMode) {
        case SplitMode.extractAll:
          config = const ExtractAllSplitConfig();
          break;
        case SplitMode.customRange:
          config = CustomRangeSplitConfig(rangeString: _customRange);
          break;
        case SplitMode.fixedInterval:
          config = IntervalSplitConfig(pagesPerSplit: int.parse(_interval));
          break;
      }
      
      final groups = config.resolve(_activeJob!.pageCount!);
      
      updateProgress(0.5, 'Splitting PDF pages...');

      final result = await PdfSplitService.splitPdf(_activeJob!.bytes!, _activeJob!.fileName, groups);

      if (!result.isSuccess) {
        throw Exception(result.error ?? 'Unknown error occurred.');
      }

      updateProgress(0.8, 'Saving files...');
      
      String finalExtension = '.pdf';
      int finalSize = 0;
      String savedPath = '';
      String outputFolder = '';
      String finalName = '';
      
      if (result.hasMultipleFiles) {
        updateProgress(0.8, 'Creating ZIP archive...');
        
        final zipBytes = await compute(ZipUtils.createZip, result.files);
        finalName = '${_outputConfig!.filename}.zip';
        final requestedOutPath = p.join(_outputConfig!.folderPath, finalName);
        
        updateProgress(0.9, 'Saving ZIP...');
        final savedFile = await _outputService.saveFile(requestedOutPath, zipBytes, _outputConfig!);
        
        savedPath = savedFile.absolute.path;
        outputFolder = savedFile.parent.absolute.path;
        finalSize = zipBytes.length;
        finalExtension = '.zip';
        finalName = p.basename(savedFile.path);
        
      } else {
        updateProgress(0.9, 'Saving PDF...');
        
        final fileOut = result.files.first;
        finalName = '${_outputConfig!.filename}.pdf';
        final requestedOutPath = p.join(_outputConfig!.folderPath, finalName);
        
        final savedFile = await _outputService.saveFile(requestedOutPath, fileOut.bytes, _outputConfig!);
        
        savedPath = savedFile.absolute.path;
        outputFolder = savedFile.parent.absolute.path;
        finalSize = fileOut.bytes.length;
        finalExtension = '.pdf';
        finalName = p.basename(savedFile.path);
      }
      
      final stopTime = DateTime.now();
      final durationMs = stopTime.difference(startTime).inMilliseconds;

      final resultData = ConversionResultData(
        outputFilename: finalName,
        outputPath: savedPath,
        outputFolder: outputFolder,
        processingTimeMs: durationMs,
        statistics: [
          ConversionStatistic('Original Size', '${(_activeJob!.fileSize / 1024).toStringAsFixed(1)} KB'),
          ConversionStatistic('Output Files', '${result.files.length} files'),
          ConversionStatistic('Output Format', finalExtension.toUpperCase()),
          ConversionStatistic('Processing Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
        ],
      );
      
      // Record in Workspace
      await _workspaceRepository.insertRecord(WorkspaceRecord(
        id: const Uuid().v4(),
        toolId: 'pdf_split',
        toolName: 'Split PDF',
        inputPath: _activeJob!.filePath,
        outputPath: savedPath,
        outputFolder: outputFolder,
        outputExtension: finalExtension,
        inputSize: _activeJob!.fileSize,
        outputSize: finalSize,
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
