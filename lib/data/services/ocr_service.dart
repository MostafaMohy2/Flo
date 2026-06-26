import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/api_constants.dart';

class OcrService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// openrouter/free automatically picks a free vision-capable model
  /// from OpenRouter's pool — same API key, no hardcoded model that can 404.
  Future<Map<String, dynamic>?> parseReceipt(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Img = base64Encode(bytes);
    final mimeType = imageFile.mimeType ?? 'image/jpeg';

    final response = await _dio.post(
      ApiConstants.openRouterBaseUrl,
      options: Options(headers: {
        'Authorization': 'Bearer ${ApiConstants.apiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': ApiConstants.appReferer,
        'X-OpenRouter-Title': ApiConstants.appTitle,
      }),
      data: jsonEncode({
        'model': 'google/gemma-4-31b-it:free',
        'max_tokens': 2000,
        'temperature': 0.0,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Img',
                },
              },
              {
                'type': 'text',
                'text': '''Analyze this receipt or payment confirmation image.

Return ONLY a raw JSON object with no markdown, no code fences, no explanation:
{
  "amount": <total/paid amount as a number, null if not found>,
  "merchantName": <store name string, or null for digital payments like Paymob with no store>,
  "category": "<one of: food, transport, shopping, bills, health, entertainment, tech, other>",
  "date": "<YYYY-MM-DD, null if not found>"
}

Rules:
- amount is always the priority.
- Paymob/Fawry/digital receipts with no store name: merchantName = null.
- pharmacy/medicine = health. restaurant/cafe/grocery = food. electricity/water/internet = bills. taxi/fuel = transport. unknown digital payment = other.
- Never invent data. Return null for anything not visible.''',
              },
            ],
          },
        ],
      }),
    );

    final rawContent = response.data['choices'][0]['message']['content'];
    if (rawContent == null) {
      throw Exception('The AI model returned no text. Try scanning again.');
    }
    final content = (rawContent as String)
        .trim()
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final parsed = jsonDecode(content) as Map<String, dynamic>;

    DateTime? date;
    final rawDate = parsed['date'];
    if (rawDate != null &&
        rawDate.toString() != 'null' &&
        rawDate.toString().isNotEmpty) {
      try {
        date = DateTime.parse(rawDate.toString());
      } catch (_) {}
    }

    return {
      'amount': parsed['amount'] != null
          ? (parsed['amount'] as num).toDouble()
          : null,
      'merchantName': parsed['merchantName'],
      'category': parsed['category'],
      'date': date,
    };
  }

  void dispose() {}
}
