import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../shared/model/document_job.dart';
import '../../shared/model/document_progress_state.dart';
import '../../shared/model/conversion_result_data.dart';
import '../../shared/model/output_configuration.dart';
import '../../shared/services/output_service.dart';
import '../../../workspace/domain/models/workspace_record.dart';
import '../../../workspace/domain/workspace_repository.dart';
import '../domain/word_to_pdf_service.dart';
import '../../../../core/engine/manager/engine_manager.dart';
import '../../../../core/premium/feature_gate_service.dart';
import '../../../../core/utils/tool_registry.dart';

class WordToPdfController extends ChangeNotifier with DocumentProgressState {
  final WordToPdfService _service;
  final EngineManager _engineManager;
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;
  final FeatureGateService _featureGateService;

  DocumentJob? _job;
  DocumentJob? get job => _job;
  bool get hasJob => _job != null;

  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  bool _needsEngineDownload = false;
  bool get needsEngineDownload => _needsEngineDownload;
  
  String? _requiredEngineId;
  String? get requiredEngineId => _requiredEngineId;

  bool _isPlatformSupported = true;
  bool get isPlatformSupported => _isPlatformSupported;

  WordToPdfController(this._service, this._engineManager, this._outputService, this._workspaceRepository, this._featureGateService) {
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final engine = await _service.resolveEngine();
    _isPlatformSupported = engine != null;
    notifyListeners();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final path = kIsWeb ? '' : (file.path ?? '');
      
      _job = DocumentJob(
        id: DateTime.now().microsecondsSinceEpoch.toString() + file.name,
        filePath: path,
        fileName: file.name,
        fileSize: file.size,
        bytes: file.bytes,
      );
      
      final defaultFolder = await _outputService.getDefaultOutputFolder();
      final baseName = p.basenameWithoutExtension(file.name);
      _outputConfig = OutputConfiguration(
        filename: baseName,
        folderPath: defaultFolder,
      );
      
      _needsEngineDownload = false;
      _requiredEngineId = null;
      notifyListeners();
    }
  }

  void removeFile() {
    _job = null;
    _outputConfig = null;
    _needsEngineDownload = false;
    _requiredEngineId = null;
    resetProgress();
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

  Future<void> startConversion() async {
    if (_job == null || _outputConfig == null || isProcessing) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Word to PDF is not supported offline on Web.');
      return;
    }

    try {
      _featureGateService.ensureAccess(ToolIds.wordToPdf);
    } catch (e) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: e.toString());
      return;
    }

    setProcessingState(isProcessing: true, progress: 0.1, statusMessage: 'Preparing conversion engine...');
    _needsEngineDownload = false;

    final progressCtrl = StreamController<double>();
    progressCtrl.stream.listen((p) {
      updateProgress(p, 'Converting document...');
    });

    final startTime = DateTime.now();

    try {
      final timestamp = startTime.millisecondsSinceEpoch;
      final outFileName = '${_outputConfig!.filename}.pdf';
      final requestedOutPath = p.join(_outputConfig!.folderPath, outFileName);

      final tempDir = await getTemporaryDirectory();
      final tempInput = File(p.join(tempDir.path, 'temp_$timestamp.docx'));
      if (_job!.bytes != null) {
        await tempInput.writeAsBytes(_job!.bytes!);
      } else {
        await File(_job!.filePath).copy(tempInput.path);
      }

      final result = await _service.convertWordToPdf(
        tempInput,
        outFileName,
        progress: progressCtrl,
      );

      if (result.needsEngineDownload) {
        _needsEngineDownload = true;
        _requiredEngineId = result.requiredEngineId;
        setProcessingState(isProcessing: false, progress: 0, statusMessage: result.error ?? 'Required engine is missing.');
      } else if (!result.isSuccess) {
        setProcessingState(isProcessing: false, progress: 0, statusMessage: result.error ?? 'Unknown error occurred.');
      } else {
        final stopTime = DateTime.now();
        final durationMs = stopTime.difference(startTime).inMilliseconds;
        final outBytes = result.files.first.bytes;
        
        final savedFile = await _outputService.saveFile(requestedOutPath, outBytes, _outputConfig!);
        
        final resultData = ConversionResultData(
          outputFilename: p.basename(savedFile.path),
          outputPath: savedFile.absolute.path,
          outputFolder: savedFile.parent.absolute.path,
          processingTimeMs: durationMs,
          statistics: [
            ConversionStatistic('Input Size', '${(_job!.fileSize / 1024).toStringAsFixed(1)} KB'),
            ConversionStatistic('Output Size', '${(outBytes.length / 1024).toStringAsFixed(1)} KB'),
            ConversionStatistic('Processing Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
            const ConversionStatistic('Output Type', 'PDF Document'),
          ],
        );
        
        // Record in Workspace
        await _workspaceRepository.insertRecord(WorkspaceRecord(
          id: const Uuid().v4(),
          toolId: 'word_to_pdf',
          toolName: 'Word to PDF',
          inputPath: _job!.filePath,
          outputPath: savedFile.absolute.path,
          outputFolder: savedFile.parent.absolute.path,
          outputExtension: '.pdf',
          inputSize: _job!.fileSize,
          outputSize: outBytes.length,
          processingTime: durationMs,
          createdAt: DateTime.now(),
          status: 'success',
        ));
        
        setSuccessState(resultData);
      }
      
      if (await tempInput.exists()) {
        await tempInput.delete();
      }
      
    } catch (e) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Conversion failed: $e');
    } finally {
      progressCtrl.close();
    }
  }

  Future<void> downloadRequiredEngine() async {
    if (_requiredEngineId == null || isProcessing) return;
    
    setProcessingState(isProcessing: true, progress: 0, statusMessage: 'Downloading engine...');
    
    try {
      final sub = _engineManager.watchEngine(_requiredEngineId!).listen((info) {
        if (info.downloadProgress != null) {
          updateProgress(info.downloadProgress!, 'Downloading engine... ${(info.downloadProgress! * 100).toInt()}%');
        }
      });
      
      await _engineManager.installEngine(_requiredEngineId!);
      await sub.cancel();
      
      _needsEngineDownload = false;
      _requiredEngineId = null;
      setProcessingState(isProcessing: false, progress: 1.0, statusMessage: 'Engine installed successfully. You can now convert your document.');
    } catch (e) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Failed to install engine: $e');
    }
  }
}
