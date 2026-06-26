import 'dart:typed_data';

/// Stub for environments where neither dart:html nor dart:io is available.
Future<void> downloadExcel(Uint8List bytes, String fileName) async {}
