import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../shared/model/document_job.dart';
import '../../shared/model/document_progress_state.dart';
import '../../shared/model/conversion_result_data.dart';
import '../../shared/model/output_configuration.dart';
import '../../shared/services/pdf_core_service.dart';
import '../../shared/services/pdf_to_images_service.dart';
import '../../shared/services/output_service.dart';
import '../model/pdf_to_images_config.dart';
import '../../../../core/utils/zip_utils.dart';
import '../../shared/model/split_config.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';
import 'package:path/path.dart' as p;

class PdfToImagesController extends ChangeNotifier with DocumentProgressState {
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;

  DocumentJob? _activeJob;
  DocumentJob? get activeJob => _activeJob;

  PdfToImagesConfig _config = const PdfToImagesConfig();
  PdfToImagesConfig get config => _config;

  String _customRange = '';
  String get customRange => _customRange;

  bool _isCustomRangeSelected = false;
  bool get isCustomRangeSelected => _isCustomRangeSelected;

  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  PdfToImagesController(this._outputService, this._workspaceRepository);

  void updateConfig(PdfToImagesConfig newConfig) {
    _config = newConfig;
    notifyListeners();
  }

  void setCustomRange(String range) {
    _customRange = range;
    if (_isCustomRangeSelected) {
      _config = _config.copyWith(rangeConfig: CustomRangeSplitConfig(rangeString: _customRange));
    }
    notifyListeners();
  }

  void toggleRangeMode(bool isCustom) {
    _isCustomRangeSelected = isCustom;
    if (isCustom) {
      _config = _config.copyWith(rangeConfig: CustomRangeSplitConfig(rangeString: _customRange));
    } else {
      _config = _config.copyWith(rangeConfig: const ExtractAllSplitConfig());
    }
    notifyListeners();
  }

  bool get canConvert {
    if (_activeJob == null || isProcessing) return false;
    
    if (_isCustomRangeSelected) {
      if (_customRange.trim().isEmpty) return false;
      final groups = _config.rangeConfig.resolve(_activeJob!.pageCount!);
      return groups.isNotEmpty;
    }
    return true; 
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
            filename: '${baseName}_images',
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

  Future<void> convertToImages() async {
    if (!canConvert || _activeJob == null || _outputConfig == null) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Offline conversion is not supported on Web.');
      return;
    }

    try {
      setProcessingState(isProcessing: true, progress: 0.1, statusMessage: 'Rasterizing pages (this may take a moment)...');
      
      final startTime = DateTime.now();

      final baseName = _outputConfig!.filename;

      final result = await PdfToImagesService.convertToImages(
        _activeJob!.bytes!,
        _config,
        baseName,
      );

      if (!result.isSuccess) {
        throw Exception(result.error ?? 'Unknown error occurred.');
      }

      updateProgress(0.7, 'Saving files...');
      
      String finalExtension = '.${_config.format.name.toLowerCase()}';
      int finalSize = 0;
      String savedPath = '';
      String outputFolder = '';
      String finalName = '';
      
      if (result.hasMultipleFiles) {
        updateProgress(0.7, 'Creating ZIP archive...');
        
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
        updateProgress(0.9, 'Saving Image...');
        
        final fileOut = result.files.first;
        finalName = '${_outputConfig!.filename}$finalExtension';
        final requestedOutPath = p.join(_outputConfig!.folderPath, finalName);
        
        final savedFile = await _outputService.saveFile(requestedOutPath, fileOut.bytes, _outputConfig!);
        
        savedPath = savedFile.absolute.path;
        outputFolder = savedFile.parent.absolute.path;
        finalSize = fileOut.bytes.length;
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
          ConversionStatistic('Output Images', '${result.files.length} images'),
          ConversionStatistic('Output Format', finalExtension.toUpperCase()),
          ConversionStatistic('Processing Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
        ],
      );
      
      // Record in Workspace
      await _workspaceRepository.insertRecord(WorkspaceRecord(
        id: const Uuid().v4(),
        toolId: 'pdf_to_images',
        toolName: 'PDF to Images',
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
