import 'dart:io';
import 'package:get_it/get_it.dart';
import '../storage/storage_service.dart';
import '../../modules/workspace/data/database_helper.dart';
import '../services/runtime_capability_service.dart';

import '../engine/manager/engine_manager.dart';
import '../engine/registry/engine_registry.dart';
import '../engine/models/engine_info.dart';

import '../../modules/document/pdf_to_word/domain/pdf_to_word_engine.dart';
import '../../modules/document/pdf_to_word/data/engines/python_pdf_to_word_engine.dart';
import '../../modules/document/pdf_to_word/domain/pdf_to_word_service.dart';
import '../../modules/document/pdf_to_word/controller/pdf_to_word_controller.dart';

import '../../modules/document/pptx_to_pdf/domain/pptx_to_pdf_engine.dart';
import '../../modules/document/pptx_to_pdf/data/engines/com_pptx_to_pdf_engine.dart';
import '../../modules/document/pptx_to_pdf/data/engines/libreoffice_pptx_to_pdf_engine.dart';
import '../../modules/document/pptx_to_pdf/domain/pptx_to_pdf_service.dart';
import '../../modules/document/pptx_to_pdf/controller/pptx_to_pdf_controller.dart';

import '../../modules/document/word_to_pdf/domain/word_to_pdf_engine.dart';
import '../../modules/document/word_to_pdf/data/engines/com_word_to_pdf_engine.dart';
import '../../modules/document/word_to_pdf/data/engines/libreoffice_word_to_pdf_engine.dart';
import '../../modules/document/word_to_pdf/domain/word_to_pdf_service.dart';
import '../../modules/document/word_to_pdf/controller/word_to_pdf_controller.dart';

import '../../modules/document/pdf_compress/domain/pdf_compress_engine.dart';
import '../../modules/document/pdf_compress/data/engines/python_pdf_compress_engine.dart';
import '../../modules/document/pdf_compress/domain/pdf_compress_service.dart';
import '../../modules/document/pdf_compress/controller/pdf_compress_controller.dart';

import '../../modules/document/pdf_merge/controller/pdf_merge_controller.dart';
import '../../modules/document/pdf_split/controller/pdf_split_controller.dart';
import '../../modules/document/images_to_pdf/controller/images_to_pdf_controller.dart';
import '../../modules/document/pdf_to_images/controller/pdf_to_images_controller.dart';

import '../../modules/document/shared/services/output_service.dart';
import '../../modules/workspace/domain/workspace_repository.dart';
import '../../modules/workspace/presentation/controller/workspace_controller.dart';
import '../../modules/settings/controller/user_preferences_controller.dart';
import '../../modules/settings/services/user_preferences_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  print('  [sl] 1. Storage Service');
  final usePortable = Platform.isWindows;
  print('  [sl] 1.1 initializing StorageService');
  final storageService = await StorageService.initialize(usePortableMode: usePortable);
  print('  [sl] 1.2 registering StorageService');
  sl.registerSingleton<StorageService>(storageService);

  print('  [sl] 1.5 Database Helper');
  final dbHelper = WorkspaceDatabaseHelper(sl<StorageService>());
  sl.registerSingleton<WorkspaceDatabaseHelper>(dbHelper);

  print('  [sl] 1.6 User Preferences Service');
  final userPrefsService = UserPreferencesService(sl<StorageService>());
  await userPrefsService.init();
  sl.registerSingleton<UserPreferencesService>(userPrefsService);

  print('  [sl] 1.7 Runtime Capability Service');
  final runtimeCapabilityService = RuntimeCapabilityService();
  await runtimeCapabilityService.init();
  sl.registerSingleton<RuntimeCapabilityService>(runtimeCapabilityService);

  print('  [sl] 2. Core Engines Infrastructure');
  sl.registerLazySingleton<EngineManager>(() {
    final manager = EngineManager();
    // Register known external engines
    manager.registerEngineMetadata(const EngineInfo(
      id: 'org.dastra.engine.pdf2docx',
      name: 'Python PDF to Word Engine',
      type: EngineType.cli,
      status: EngineStatus.notInstalled, // Forces download UI check for MVP
      sizeBytes: 45000000, // 45MB
    ));
    manager.registerEngineMetadata(const EngineInfo(
      id: 'org.libreoffice.headless',
      name: 'LibreOffice Portable Engine',
      type: EngineType.cli,
      status: EngineStatus.notInstalled,
      sizeBytes: 250000000, // 250MB
    ));
    manager.registerEngineMetadata(const EngineInfo(
      id: 'org.dastra.engine.pdfcompress',
      name: 'Python PDF Compress Engine',
      type: EngineType.cli,
      status: EngineStatus.notInstalled, // Forces download UI check for MVP
      sizeBytes: 15000000, // 15MB
    ));
    return manager;
  });

  sl.registerLazySingleton<EngineRegistry>(() {
    final registry = EngineRegistry();
    final manager = sl<EngineManager>();
    final storage = sl<StorageService>();
    
    // Register PDF -> Word implementations
    registry.registerEngine<PdfToWordEngine>(PythonPdfToWordEngine(manager, storage), priority: 0);
    
    // Register PPTX -> PDF implementations
    registry.registerEngine<PptxToPdfEngine>(ComPptxToPdfEngine(storage), priority: 0); // Primary (Fast, 0MB)
    registry.registerEngine<PptxToPdfEngine>(LibreOfficePptxToPdfEngine(manager), priority: 1); // Fallback
    
    // Register Word -> PDF implementations
    registry.registerEngine<WordToPdfEngine>(ComWordToPdfEngine(storage), priority: 0); // Primary (Fast, 0MB)
    registry.registerEngine<WordToPdfEngine>(LibreOfficeWordToPdfEngine(manager), priority: 1); // Fallback
    
    // Register PDF Compress implementations
    registry.registerEngine<PdfCompressEngine>(PythonPdfCompressEngine(manager, storage), priority: 0);
    
    return registry;
  });

  // 3. Services
  sl.registerLazySingleton<WorkspaceRepository>(() => WorkspaceRepository(sl()));
  sl.registerLazySingleton<OutputService>(() => OutputService(sl(), sl()));
  
  sl.registerLazySingleton<PdfToWordService>(() => PdfToWordService(sl()));
  sl.registerLazySingleton<PptxToPdfService>(() => PptxToPdfService(sl()));
  sl.registerLazySingleton<WordToPdfService>(() => WordToPdfService(sl()));
  sl.registerLazySingleton<PdfCompressService>(() => PdfCompressService(sl()));

  // 4. Controllers
  sl.registerFactory<PdfToWordController>(() => PdfToWordController(sl(), sl(), sl(), sl()));
  sl.registerFactory<PptxToPdfController>(() => PptxToPdfController(sl(), sl(), sl(), sl()));
  sl.registerFactory<WordToPdfController>(() => WordToPdfController(sl(), sl(), sl(), sl()));
  sl.registerFactory<PdfCompressController>(() => PdfCompressController(sl(), sl(), sl(), sl()));

  sl.registerFactory<PdfMergeController>(() => PdfMergeController(sl(), sl()));
  sl.registerFactory<PdfSplitController>(() => PdfSplitController(sl(), sl()));
  sl.registerFactory<ImagesToPdfController>(() => ImagesToPdfController(sl(), sl()));
  sl.registerFactory<PdfToImagesController>(() => PdfToImagesController(sl(), sl()));
  sl.registerFactory<WorkspaceController>(() => WorkspaceController(repository: sl()));
  sl.registerLazySingleton<UserPreferencesController>(() => UserPreferencesController(sl(), sl(), sl()));
}
