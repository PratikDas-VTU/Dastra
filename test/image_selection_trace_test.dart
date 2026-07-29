import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dastra/modules/image/image_converter/controller/image_converter_controller.dart';
import 'dart:typed_data';

void main() {
  test('Trace ImageConverterController addPickerFiles', () async {
    final controller = ImageConverterController();
    
    // Create a mock PlatformFile
    final dummyBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1]); // tiny PNG
    final file = PlatformFile(
      name: 'test.png',
      size: dummyBytes.length,
      bytes: dummyBytes,
      path: '/mock/test.png',
    );

    try {
      await controller.addPickerFiles([file]);
      print('Jobs count: ${controller.jobs.length}');
      if (controller.jobs.isNotEmpty) {
        final job = controller.jobs.first;
        print('Job name: ${job.fileName}, resolution: ${job.resolution}, target: ${job.targetFormat}');
      }
    } catch (e, stack) {
      print('Exception caught during addPickerFiles: $e');
      print(stack);
    }
  });
}
