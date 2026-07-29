import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/modules/security/password_generator/password_generator_screen.dart';

void main() {
  testWidgets('Dump PasswordGeneratorScreen constraints', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: PasswordGeneratorScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Dump the render tree
    debugDumpRenderTree();
  });
}
