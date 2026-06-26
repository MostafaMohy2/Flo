import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves the file to temp storage and opens the system share sheet on mobile.
Future<void> downloadExcel(Uint8List bytes, String fileName) async {
  final dir  = await getTemporaryDirectory();
  final path = '${dir.path}/$fileName';
  await File(path).writeAsBytes(bytes, flush: true);
  await Share.shareXFiles(
    [XFile(path, mimeType:
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
    subject: fileName,
  );
}
