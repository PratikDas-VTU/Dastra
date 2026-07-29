import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../../modules/document/shared/model/pdf_operation_result.dart';

class ZipUtils {
  ZipUtils._();

  /// Compresses a list of [PdfOutputFile]s into a single ZIP byte array.
  static Uint8List createZip(List<PdfOutputFile> files) {
    final archive = Archive();
    
    for (final file in files) {
      final archiveFile = ArchiveFile(
        file.fileName, 
        file.bytes.length, 
        file.bytes,
      );
      archive.addFile(archiveFile);
    }
    
    final ZipEncoder encoder = ZipEncoder();
    final List<int> zipData = encoder.encode(archive);
    
    return Uint8List.fromList(zipData);
  }
}
