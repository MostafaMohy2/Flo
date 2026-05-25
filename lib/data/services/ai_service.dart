import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../models/transaction.dart';
import '../models/anomaly_result.dart';

class AiService {
  final Dio _dio;
  final String _apiKey;

  final String _baseUrl = ApiConstants.activeBaseUrl;
  final String _model   = ApiConstants.activeModel;

  AiService({required String apiKey, required Dio dio})
      : _apiKey = apiKey,
        _dio    = dio;

  // ── Natural language query ────────────────────────────────────

  Future<String> querySpending(
    String userQuestion,
    List<Transaction> transactions,
  ) async {
    final context = _buildTransactionContext(transactions);
    return _chat([
      {
        'role': 'system',
        'content': '''You are Flo, a smart financial assistant.
The user's recent transactions: $context
Answer questions about their spending clearly and concisely.
Always reference specific numbers. Keep responses under 3 sentences.''',
      },
      {'role': 'user', 'content': userQuestion},
    ]);
  }

  // ── Anomaly detection ─────────────────────────────────────────

  Future<AnomalyResult> detectAnomalies({
    required List<Transaction> thisWeek,
    required List<Transaction> lastFourWeeks,
  }) async {
    final prompt = '''
Compare these two sets of transactions and detect spending anomalies.

This week: ${_buildTransactionContext(thisWeek)}
Last 4 weeks average: ${_buildTransactionContext(lastFourWeeks)}

Respond ONLY with a valid JSON object, no extra text:
{
  "has_anomaly": true/false,
  "category": "category name or null",
  "current_week_amount": 0.0,
  "average_week_amount": 0.0,
  "percentage_increase": 0.0,
  "message": "short human-readable summary"
}
''';

    try {
      final response = await _chat([
        {
          'role': 'system',
          'content': 'You are a financial anomaly detector. Respond ONLY in valid JSON.',
        },
        {'role': 'user', 'content': prompt},
      ]);
      final cleaned = response.replaceAll(RegExp(r'```json|```'), '').trim();
      return AnomalyResult.fromJson(jsonDecode(cleaned));
    } catch (_) {
      return AnomalyResult.none();
    }
  }

  // ── Internal ──────────────────────────────────────────────────

  Future<String> _chat(List<Map<String, String>> messages) async {
    try {
      final res = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type':       'application/json',
            'Authorization':      'Bearer $_apiKey',
            'HTTP-Referer':       ApiConstants.appReferer,
            'X-OpenRouter-Title': ApiConstants.appTitle,
          },
          sendTimeout:    const Duration(seconds: ApiConstants.requestTimeout),
          receiveTimeout: const Duration(seconds: ApiConstants.requestTimeout),
        ),
        data: {
          'model':       _model,
          'max_tokens':  ApiConstants.maxTokens,
          'temperature': ApiConstants.temperature,
          'messages':    messages,
        },
      );

      return res.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body   = e.response?.data?.toString() ?? 'no response body';
      throw AiFailure(
        status != null
            ? 'API error $status: $body'
            : 'Network error: ${e.message}',
      );
    } catch (e) {
      throw AiFailure(e.toString());
    }
  }

  String _buildTransactionContext(List<Transaction> transactions) {
    if (transactions.isEmpty) return 'No transactions found.';
    return transactions
        .map((t) =>
            '${t.merchantName} | ${t.category.name} | \$${t.amount.toStringAsFixed(2)} | ${t.date.toIso8601String().substring(0, 10)}')
        .join('\n');
  }
}
