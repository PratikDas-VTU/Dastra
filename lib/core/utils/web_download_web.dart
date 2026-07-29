// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

void downloadBase64Web(String base64, String filename, String format) {
  final element = html.AnchorElement(
      href: 'data:image/${format.toLowerCase()};base64,$base64')
    ..setAttribute('download', filename)
    ..style.display = 'none';

  html.document.body?.children.add(element);
  element.click();
  element.remove();
}

void downloadFileWeb(String filename, Uint8List bytes) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  final element = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..style.display = 'none';

  html.document.body?.children.add(element);
  element.click();
  
  // Cleanup
  element.remove();
  html.Url.revokeObjectUrl(url);
}
