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
import '../domain/pdf_compress_service.dart';
import '../model/pdf_compress_preset.dart';
import '../../../../core/engine/manager/engine_manager.dart';

class PdfCompressController extends ChangeNotifier with DocumentProgressState {
  final PdfCompressService _service;
  final EngineManager _engineManager;
  final OutputService _outputService;
  final WorkspaceRepository _workspaceRepository;

  DocumentJob? _job;
  DocumentJob? get job => _job;
  bool get hasJob => _job != null;

  PdfCompressPreset _preset = PdfCompressPreset.medium;
  PdfCompressPreset get preset => _preset;

  OutputConfiguration? _outputConfig;
  OutputConfiguration? get outputConfig => _outputConfig;

  bool _needsEngineDownload = false;
  bool get needsEngineDownload => _needsEngineDownload;
  
  String? _requiredEngineId;
  String? get requiredEngineId => _requiredEngineId;

  bool _isPlatformSupported = true;
  bool get isPlatformSupported => _isPlatformSupported;

  PdfCompressController(this._service, this._engineManager, this._outputService, this._workspaceRepository) {
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final engine = await _service.resolveEngine();
    _isPlatformSupported = engine != null;
    notifyListeners();
  }

  void setPreset(PdfCompressPreset p) {
    _preset = p;
    notifyListeners();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
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
        filename: '${baseName}_compressed',
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

  Future<void> startCompression() async {
    if (_job == null || _outputConfig == null || isProcessing) return;

    if (kIsWeb) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'PDF Compress is not supported offline on Web.');
      return;
    }

    setProcessingState(isProcessing: true, progress: 0.1, statusMessage: 'Preparing compression engine...');
    _needsEngineDownload = false;

    final progressCtrl = StreamController<double>();
    progressCtrl.stream.listen((p) {
      updateProgress(p, 'Compressing document...');
    });

    final startTime = DateTime.now();

    try {
      final timestamp = startTime.millisecondsSinceEpoch;
      final outFileName = '${_outputConfig!.filename}.pdf';
      final requestedOutPath = p.join(_outputConfig!.folderPath, outFileName);

      final tempDir = await getTemporaryDirectory();
      final tempInput = File(p.join(tempDir.path, 'temp_$timestamp.pdf'));
      if (_job!.bytes != null) {
        await tempInput.writeAsBytes(_job!.bytes!);
      } else {
        await File(_job!.filePath).copy(tempInput.path);
      }

      final result = await _service.compressPdf(
        tempInput,
        outFileName,
        _preset,
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
        
        double reduction = 0.0;
        if (_job!.fileSize > 0) {
          reduction = ((_job!.fileSize - outBytes.length) / _job!.fileSize) * 100;
        }
        final reductionStr = reduction > 0 ? '-${reduction.toStringAsFixed(1)}%' : '+${(-reduction).toStringAsFixed(1)}%';

        final resultData = ConversionResultData(
          outputFilename: p.basename(savedFile.path),
          outputPath: savedFile.absolute.path,
          outputFolder: savedFile.parent.absolute.path,
          processingTimeMs: durationMs,
          statistics: [
            ConversionStatistic('Original Size', '${(_job!.fileSize / 1024).toStringAsFixed(1)} KB'),
            ConversionStatistic('Compressed', '${(outBytes.length / 1024).toStringAsFixed(1)} KB'),
            ConversionStatistic('Reduction', reductionStr),
            ConversionStatistic('Time', '${(durationMs / 1000).toStringAsFixed(2)}s'),
          ],
        );
        
        // Record in Workspace
        await _workspaceRepository.insertRecord(WorkspaceRecord(
          id: const Uuid().v4(),
          toolId: 'pdf_compress',
          toolName: 'PDF Compress',
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
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Compression failed: $e');
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
      setProcessingState(isProcessing: false, progress: 1.0, statusMessage: 'Engine installed successfully. You can now compress your document.');
    } catch (e) {
      setProcessingState(isProcessing: false, progress: 0, statusMessage: 'Failed to install engine: $e');
    }
  }
}
