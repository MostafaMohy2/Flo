// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Triggers a browser file download on web.
Future<void> downloadExcel(Uint8List bytes, String fileName) async {
  const mimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  final blob   = html.Blob([bytes], mimeType);
  final url    = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
