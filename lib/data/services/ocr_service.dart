/// OCR is not supported on web. On mobile it requires the
/// google_mlkit_text_recognition package which cannot compile to web.
/// The scan receipt UI falls back gracefully when null is returned.
class OcrService {
  Future<Map<String, dynamic>?> parseReceipt(String imagePath) async {
    // MLKit removed for web compatibility — returns null so the
    // Add Expense screen stays in manual-entry mode.
    return null;
  }

  void dispose() {}
}
