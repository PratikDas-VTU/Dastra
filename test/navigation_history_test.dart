import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/main.dart';
import 'package:dastra/core/navigation/app_router.dart';
import 'package:dastra/core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:dastra/modules/settings/controller/user_preferences_controller.dart';
import 'package:dastra/core/services/runtime_capability_service.dart';
import 'helpers/test_bootstrap.dart';

void main() {
  setUpAll(() async {
    await bootstrapTest();
  });

  tearDownAll(() async {
    await teardownTest();
  });

  testWidgets('Navigation history test: Dashboard -> Image -> Converter -> Back', (WidgetTester tester) async {
    await tester.pumpWidget(
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
    await tester.pump(const Duration(seconds: 1));

    AppRouter.router.go('/image');
    await tester.pump(const Duration(seconds: 1));

    AppRouter.router.go('/image/converter');
    await tester.pump(const Duration(seconds: 1));
    expect(AppRouter.router.routerDelegate.currentConfiguration.uri.toString(), '/image/converter');

    // Simulate Back button by popping
    AppRouter.router.pop();
    await tester.pump(const Duration(seconds: 1));
    
    expect(AppRouter.router.routerDelegate.currentConfiguration.uri.toString(), '/image', reason: 'Back from converter should go to image');
  });
}
