import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart' as model;
import '../models/user.dart';

class LocalDbService {
  static const _txBox       = 'transactions_v2';
  static const _settingsBox = 'settings_v2';
  static const _usersBox    = 'users_v2';

  static bool _initialized = false;

  /// Call once in main() before runApp.
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();

    // All boxes store JSON strings — Hive handles String natively on web
    await Hive.openBox<String>(_txBox);
    await Hive.openBox<String>(_settingsBox);
    await Hive.openBox<String>(_usersBox);

    // Write default settings only on fresh install
    final s = Hive.box<String>(_settingsBox);
    await _putIfAbsent(s, 'currency',               'USD');
    await _putIfAbsent(s, 'monthly_budget',         '3000');
    await _putIfAbsent(s, 'ai_alerts_enabled',      'true');
    await _putIfAbsent(s, 'weekly_summary_enabled', 'true');
    await _putIfAbsent(s, 'last_anomaly_check',     '');
    await _putIfAbsent(s, 'current_user_id',        '');
    await _putIfAbsent(s, 'theme_mode',             'light');

    _initialized = true;
  }

  static Future<void> _putIfAbsent(
      Box<String> box, String key, String value) async {
    if (!box.containsKey(key)) await box.put(key, value);
  }

  // ── Transactions ──────────────────────────────────────────────

  Future<void> insertTransaction(model.Transaction t) async {
    await Hive.box<String>(_txBox).put(t.id, jsonEncode(_txToMap(t)));
  }

  Future<void> insertTransactions(List<model.Transaction> list) async {
    final box     = Hive.box<String>(_txBox);
    final entries = <String, String>{
      for (final t in list) t.id: jsonEncode(_txToMap(t)),
    };
    await box.putAll(entries);
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    return _sortedTx(_allTxMaps());
  }

  Future<List<model.Transaction>> getTransactionsByMonth(
      int year, int month) async {
    final start = DateTime(year, month);
    final end   = DateTime(year, month + 1);
    final maps  = _allTxMaps().where((m) {
      final d = DateTime.parse(m['date'] as String);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
    return _sortedTx(maps);
  }

  Future<List<model.Transaction>> getTransactionsLastNDays(int days) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final maps  = _allTxMaps()
        .where((m) => DateTime.parse(m['date'] as String).isAfter(since))
        .toList();
    return _sortedTx(maps);
  }

  Future<void> updateTransaction(model.Transaction t) async {
    await Hive.box<String>(_txBox).put(t.id, jsonEncode(_txToMap(t)));
  }

  Future<void> deleteTransaction(String id) async {
    await Hive.box<String>(_txBox).delete(id);
  }

  Future<void> deleteAllTransactions() async {
    await Hive.box<String>(_txBox).clear();
  }

  // ── Users ─────────────────────────────────────────────────────

  Future<void> insertUser(User user) async {
    final exists = _allUserMaps().any(
      (m) => (m['email'] as String).toLowerCase() ==
          user.email.toLowerCase(),
    );
    if (exists) throw Exception('An account with this email already exists.');
    await Hive.box<String>(_usersBox)
        .put(user.id, jsonEncode(_userToMap(user)));
  }

  Future<User?> getUserByEmail(String email) async {
    final target = email.toLowerCase().trim();
    final match  = _allUserMaps()
        .where((m) => (m['email'] as String).toLowerCase() == target)
        .toList();
    return match.isEmpty ? null : _userFromMap(match.first);
  }

  Future<User?> getUserById(String id) async {
    final raw = Hive.box<String>(_usersBox).get(id);
    if (raw == null) return null;
    return _userFromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> updateUser(User user) async {
    await Hive.box<String>(_usersBox)
        .put(user.id, jsonEncode(_userToMap(user)));
  }

  // ── Settings ──────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    return Hive.box<String>(_settingsBox).get(key);
  }

  Future<void> setSetting(String key, String value) async {
    await Hive.box<String>(_settingsBox).put(key, value);
  }

  // ── Private helpers ───────────────────────────────────────────

  List<Map<String, dynamic>> _allTxMaps() {
    return Hive.box<String>(_txBox)
        .values
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  List<Map<String, dynamic>> _allUserMaps() {
    return Hive.box<String>(_usersBox)
        .values
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  List<model.Transaction> _sortedTx(List<Map<String, dynamic>> maps) {
    final list = maps.map(_txFromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Map<String, dynamic> _txToMap(model.Transaction t) => {
        'id':           t.id,
        'merchantName': t.merchantName,
        'amount':       t.amount,
        'type':         t.type.name,
        'category':     t.category.name,
        'date':         t.date.toIso8601String(),
        'note':         t.note,
        'isFlagged':    t.isFlagged,
      };

  model.Transaction _txFromMap(Map<String, dynamic> m) => model.Transaction(
        id:           m['id'] as String,
        merchantName: m['merchantName'] as String,
        amount:       (m['amount'] as num).toDouble(),
        type:         model.TransactionType.values
            .byName(m['type'] as String),
        category:     model.TransactionCategory.values
            .byName(m['category'] as String),
        date:         DateTime.parse(m['date'] as String),
        note:         m['note'] as String?,
        isFlagged:    (m['isFlagged'] as bool?) ?? false,
      );

  Map<String, dynamic> _userToMap(User u) => {
        'id':           u.id,
        'name':         u.name,
        'email':        u.email,
        'passwordHash': u.passwordHash,
        'createdAt':    u.createdAt.toIso8601String(),
      };

  User _userFromMap(Map<String, dynamic> m) => User(
        id:           m['id'] as String,
        name:         m['name'] as String,
        email:        m['email'] as String,
        passwordHash: m['passwordHash'] as String,
        createdAt:    DateTime.parse(m['createdAt'] as String),
      );
}
