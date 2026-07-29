// Dastra — Entry point
// Offline Productivity Application
// Author: Pratik Das
// Version: 1.0.0
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';

import 'package:provider/provider.dart';
import 'modules/settings/controller/user_preferences_controller.dart';
import 'core/services/runtime_capability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  // Force dark status bar icons on the overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserPreferencesController>.value(
          value: sl<UserPreferencesController>(),
        ),
        ChangeNotifierProvider<RuntimeCapabilityService>.value(
          value: sl<RuntimeCapabilityService>(),
        ),
      ],
      child: const DastraApp(),
    ),
  );
}

class DastraApp extends StatelessWidget {
  const DastraApp({super.key});

  @override
  Widget build(BuildContext context) {
    UserPreferencesController? prefs;
    try {
      prefs = context.watch<UserPreferencesController>();
    } catch (_) {}

    ThemeMode themeMode;
    switch (prefs?.profile.theme.mode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'system':
        themeMode = ThemeMode.system;
        break;
      case 'dark':
      default:
        themeMode = ThemeMode.dark;
        break;
    }

    Widget app = MaterialApp.router(
      title: 'Dastra',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // go_router
      routerConfig: AppRouter.router,
    );

    if (prefs == null && sl.isRegistered<UserPreferencesController>()) {
      app = ChangeNotifierProvider<UserPreferencesController>.value(
        value: sl<UserPreferencesController>(),
        child: app,
      );
    }

    return app;
  }
}
