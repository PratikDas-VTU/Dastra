import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dastra/modules/image/image_converter/image_converter_screen.dart';
import 'package:dastra/modules/image/image_converter/controller/image_converter_controller.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

void main() {
  testWidgets('Trace Image Selection UI', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ImageConverterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final controller = tester.element(find.byType(Scaffold)).read<ImageConverterController>();
    print('Initial Jobs count: ${controller.jobs.length}');

    final dummyBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1]); 
    final file = PlatformFile(
      name: 'test.png',
      size: dummyBytes.length,
      bytes: dummyBytes,
      path: null, // Simulate Web where path is null
    );

    try {
      await controller.addPickerFiles([file]);
      await tester.pumpAndSettle();

      print('Jobs count after add: ${controller.jobs.length}');
      
      final emptyStateFound = find.text('Browse Files').evaluate().isNotEmpty;
      print('EmptyState visible: $emptyStateFound');
      
      final previewFound = find.text('test.png').evaluate().isNotEmpty;
      print('Preview visible: $previewFound');
    } catch (e) {
      print('Exception in UI test: $e');
    }
  });
}
