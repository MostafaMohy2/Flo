import '../services/local_db_service.dart';

class SettingsRepository {
  final LocalDbService _db;
  SettingsRepository(this._db);

  Future<String?> get(String key) => _db.getSetting(key);
  Future<void> set(String key, String value) => _db.setSetting(key, value);

  Future<double> getMonthlyBudget() async {
    final v = await get('monthly_budget');
    return double.tryParse(v ?? '') ?? 3000.0;
  }

  Future<String> getCurrency() async => (await get('currency')) ?? 'USD';

  Future<bool> isAiAlertsEnabled() async =>
      (await get('ai_alerts_enabled')) == 'true';

  Future<DateTime?> getLastAnomalyCheck() async {
    final v = await get('last_anomaly_check');
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  Future<void> setLastAnomalyCheck(DateTime dt) =>
      set('last_anomaly_check', dt.toIso8601String());
}
