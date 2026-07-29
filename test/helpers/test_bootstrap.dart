import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/core/di/service_locator.dart';
import 'package:dastra/core/storage/storage_service.dart';
import 'package:dastra/core/engine/manager/engine_manager.dart';
import 'package:dastra/modules/workspace/data/database_helper.dart';
import 'package:dastra/modules/settings/controller/user_preferences_controller.dart';

/// Centralized test bootstrap to initialize DI and safely configure tests.
Future<void> bootstrapTest({bool skipOnboarding = true}) async {
  if (!sl.isRegistered<StorageService>()) {
    await setupServiceLocator();
  }
  
  if (skipOnboarding && sl.isRegistered<UserPreferencesController>()) {
    await sl<UserPreferencesController>().setHasSeenOnboarding(true);
  }
}

/// Centralized test teardown to close background isolates and streams,
/// preventing the Dart VM from hanging at the end of a test run.
Future<void> teardownTest() async {
  if (sl.isRegistered<WorkspaceDatabaseHelper>()) {
    await sl<WorkspaceDatabaseHelper>().close();
  }
  
  if (sl.isRegistered<EngineManager>()) {
    sl<EngineManager>().dispose();
  }
  
  await sl.reset();
}
