import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart' as model;
import '../models/user.dart';

class LocalDbService {
  static Database? _db;

  /// No-op on mobile — sqflite opens lazily on first use.
  static Future<void> ensureInit() async {}

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'flo.db');
    return openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY, merchantName TEXT NOT NULL, amount REAL NOT NULL,
        type TEXT NOT NULL, category TEXT NOT NULL, date TEXT NOT NULL,
        note TEXT, isFlagged INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('''
      CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)''');
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL, createdAt TEXT NOT NULL
      )''');
    for (final e in _defaults.entries) {
      await db.insert('settings', {'key': e.key, 'value': e.value});
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
          passwordHash TEXT NOT NULL, createdAt TEXT NOT NULL
        )''');
      await db.insert('settings', {'key': 'current_user_id', 'value': ''},
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static const _defaults = {
    'currency': 'USD', 'monthly_budget': '3000',
    'ai_alerts_enabled': 'true', 'weekly_summary_enabled': 'true',
    'last_anomaly_check': '', 'current_user_id': '', 'theme_mode': 'light',
  };

  // ── Transactions ──────────────────────────────────────────────

  Future<void> insertTransaction(model.Transaction t) async =>
      (await database).insert('transactions', t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> insertTransactions(List<model.Transaction> list) async {
    final db    = await database;
    final batch = db.batch();
    for (final t in list) {
      batch.insert('transactions', t.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    final maps = await (await database).query('transactions', orderBy: 'date DESC');
    return maps.map(model.Transaction.fromMap).toList();
  }

  Future<List<model.Transaction>> getTransactionsByMonth(int year, int month) async {
    final db    = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end   = DateTime(year, month + 1, 1).toIso8601String();
    final maps  = await db.query('transactions',
        where: 'date >= ? AND date < ?', whereArgs: [start, end], orderBy: 'date DESC');
    return maps.map(model.Transaction.fromMap).toList();
  }

  Future<List<model.Transaction>> getTransactionsLastNDays(int days) async {
    final db    = await database;
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final maps  = await db.query('transactions',
        where: 'date >= ?', whereArgs: [since], orderBy: 'date DESC');
    return maps.map(model.Transaction.fromMap).toList();
  }

  Future<void> updateTransaction(model.Transaction t) async =>
      (await database).update('transactions', t.toMap(),
          where: 'id = ?', whereArgs: [t.id]);

  Future<void> deleteTransaction(String id) async =>
      (await database).delete('transactions', where: 'id = ?', whereArgs: [id]);

  Future<void> deleteAllTransactions() async =>
      (await database).delete('transactions');

  // ── Users ─────────────────────────────────────────────────────

  Future<void> insertUser(User user) async =>
      (await database).insert('users', user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);

  Future<User?> getUserByEmail(String email) async {
    final res = await (await database).query('users',
        where: 'email = ?', whereArgs: [email.toLowerCase().trim()], limit: 1);
    return res.isEmpty ? null : User.fromMap(res.first);
  }

  Future<User?> getUserById(String id) async {
    final res = await (await database).query('users',
        where: 'id = ?', whereArgs: [id], limit: 1);
    return res.isEmpty ? null : User.fromMap(res.first);
  }

  Future<void> updateUser(User user) async =>
      (await database).update('users', user.toMap(),
          where: 'id = ?', whereArgs: [user.id]);

  // ── Settings ──────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final res = await (await database).query('settings',
        where: 'key = ?', whereArgs: [key]);
    return res.isEmpty ? null : res.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async =>
      (await database).insert('settings', {'key': key, 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace);
}
