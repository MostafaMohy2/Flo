import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart' as model;
import '../models/user.dart';

class LocalDbService {
  static const _txBox       = 'flo_transactions';
  static const _settingsBox = 'flo_settings';
  static const _usersBox    = 'flo_users';
  static bool   _ready      = false;

  /// Called from main() on web before runApp.
  static Future<void> ensureInit() async {
    if (_ready) return;
    await Hive.initFlutter();
    await Hive.openBox<String>(_txBox);
    await Hive.openBox<String>(_settingsBox);
    await Hive.openBox<String>(_usersBox);
    final s = Hive.box<String>(_settingsBox);
    for (final e in _defaults.entries) {
      if (!s.containsKey(e.key)) await s.put(e.key, e.value);
    }
    _ready = true;
  }

  static const _defaults = {
    'currency': 'USD', 'monthly_budget': '3000',
    'ai_alerts_enabled': 'true', 'weekly_summary_enabled': 'true',
    'last_anomaly_check': '', 'current_user_id': '', 'theme_mode': 'light',
  };

  // ── Transactions ──────────────────────────────────────────────

  Future<void> insertTransaction(model.Transaction t) async =>
      Hive.box<String>(_txBox).put(t.id, jsonEncode(_txToMap(t)));

  Future<void> insertTransactions(List<model.Transaction> list) async =>
      Hive.box<String>(_txBox).putAll(
          {for (final t in list) t.id: jsonEncode(_txToMap(t))});

  Future<List<model.Transaction>> getAllTransactions() =>
      Future.value(_sortedTx(_allTx()));

  Future<List<model.Transaction>> getTransactionsByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end   = DateTime(year, month + 1);
    return Future.value(_sortedTx(_allTx().where((m) {
      final d = DateTime.parse(m['date'] as String);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList()));
  }

  Future<List<model.Transaction>> getTransactionsLastNDays(int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    return Future.value(_sortedTx(
        _allTx().where((m) =>
            DateTime.parse(m['date'] as String).isAfter(since)).toList()));
  }

  Future<void> updateTransaction(model.Transaction t) async =>
      Hive.box<String>(_txBox).put(t.id, jsonEncode(_txToMap(t)));

  Future<void> deleteTransaction(String id) async =>
      Hive.box<String>(_txBox).delete(id);

  Future<void> deleteAllTransactions() async =>
      Hive.box<String>(_txBox).clear();

  // ── Users ─────────────────────────────────────────────────────

  Future<void> insertUser(User user) async {
    if (_allUsers().any((m) =>
        (m['email'] as String).toLowerCase() == user.email.toLowerCase())) {
      throw Exception('An account with this email already exists.');
    }
    await Hive.box<String>(_usersBox)
        .put(user.id, jsonEncode(_userToMap(user)));
  }

  Future<User?> getUserByEmail(String email) {
    final target = email.toLowerCase().trim();
    final match  = _allUsers()
        .where((m) => (m['email'] as String).toLowerCase() == target)
        .toList();
    return Future.value(match.isEmpty ? null : _userFromMap(match.first));
  }

  Future<User?> getUserById(String id) {
    final raw = Hive.box<String>(_usersBox).get(id);
    return Future.value(
        raw == null ? null : _userFromMap(jsonDecode(raw) as Map<String, dynamic>));
  }

  Future<void> updateUser(User user) async =>
      Hive.box<String>(_usersBox).put(user.id, jsonEncode(_userToMap(user)));

  // ── Settings ──────────────────────────────────────────────────

  Future<String?> getSetting(String key) =>
      Future.value(Hive.box<String>(_settingsBox).get(key));

  Future<void> setSetting(String key, String value) =>
      Hive.box<String>(_settingsBox).put(key, value);

  // ── Helpers ───────────────────────────────────────────────────

  List<Map<String, dynamic>> _allTx() => Hive.box<String>(_txBox)
      .values.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

  List<Map<String, dynamic>> _allUsers() => Hive.box<String>(_usersBox)
      .values.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();

  List<model.Transaction> _sortedTx(List<Map<String, dynamic>> maps) {
    final list = maps.map(_txFromMap).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Map<String, dynamic> _txToMap(model.Transaction t) => {
        'id': t.id, 'merchantName': t.merchantName, 'amount': t.amount,
        'type': t.type.name, 'category': t.category.name,
        'date': t.date.toIso8601String(), 'note': t.note, 'isFlagged': t.isFlagged,
      };

  model.Transaction _txFromMap(Map<String, dynamic> m) => model.Transaction(
        id: m['id'] as String, merchantName: m['merchantName'] as String,
        amount: (m['amount'] as num).toDouble(),
        type: model.TransactionType.values.byName(m['type'] as String),
        category: model.TransactionCategory.values.byName(m['category'] as String),
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?, isFlagged: (m['isFlagged'] as bool?) ?? false,
      );

  Map<String, dynamic> _userToMap(User u) => {
        'id': u.id, 'name': u.name, 'email': u.email,
        'passwordHash': u.passwordHash, 'createdAt': u.createdAt.toIso8601String(),
      };

  User _userFromMap(Map<String, dynamic> m) => User(
        id: m['id'] as String, name: m['name'] as String,
        email: m['email'] as String, passwordHash: m['passwordHash'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
      );
}
