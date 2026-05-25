import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  /// Scans an image and returns a partially-filled Transaction map
  /// The user should review and confirm before saving
  Future<Map<String, dynamic>?> parseReceipt(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(inputImage);
      final text       = recognized.text;

      return {
        'amount':       _extractAmount(text),
        'merchantName': _extractMerchant(text),
        'date':         _extractDate(text),
        'rawText':      text,
      };
    } catch (_) {
      return null;
    }
  }

  double? _extractAmount(String text) {
    // Match patterns like $12.50, 12.50, USD 12.50
    final match = RegExp(r'(?:total|amount|sum)?[\s:]*\$?\s*(\d{1,6}[.,]\d{2})',
        caseSensitive: false).firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  String? _extractMerchant(String text) {
    // First non-empty line is usually the merchant name
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.isNotEmpty ? lines.first.trim() : null;
  }

  DateTime? _extractDate(String text) {
    final match = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})').firstMatch(text);
    if (match == null) return null;
    try {
      final y = int.parse(match.group(3)!);
      final m = int.parse(match.group(2)!);
      final d = int.parse(match.group(1)!);
      return DateTime(y < 100 ? 2000 + y : y, m, d);
    } catch (_) {
      return null;
    }
  }

  void dispose() => _recognizer.close();
}
