import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/main.dart';
import 'package:dastra/core/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:dastra/modules/settings/controller/user_preferences_controller.dart';
import 'package:dastra/core/services/runtime_capability_service.dart';
import 'helpers/test_bootstrap.dart';

import 'package:flutter_animate/flutter_animate.dart';

void main() {
  setUpAll(() async {
    await bootstrapTest();
  });

  tearDownAll(() async {
    await teardownTest();
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    Animate.defaultDuration = Duration.zero;
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
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(DastraApp), findsOneWidget);
  });
}
