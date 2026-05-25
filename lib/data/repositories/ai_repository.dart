import '../models/transaction.dart';
import '../models/anomaly_result.dart';
import '../services/ai_service.dart';

class AiRepository {
  final AiService _service;
  AiRepository(this._service);

  Future<String> ask(String question, List<Transaction> transactions) =>
      _service.querySpending(question, transactions);

  Future<AnomalyResult> checkAnomalies({
    required List<Transaction> thisWeek,
    required List<Transaction> lastFourWeeks,
  }) => _service.detectAnomalies(
        thisWeek: thisWeek,
        lastFourWeeks: lastFourWeeks,
      );
}
