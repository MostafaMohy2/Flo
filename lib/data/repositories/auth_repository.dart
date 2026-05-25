import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/local_db_service.dart';

class AuthRepository {
  final LocalDbService _db;
  AuthRepository(this._db);

  // ── Password hashing ──────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes  = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ── Sign up ───────────────────────────────────────────────────

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final user = User(
      id:           const Uuid().v4(),
      name:         name.trim(),
      email:        email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt:    DateTime.now(),
    );

    await _db.insertUser(user);
    await _db.setSetting('current_user_id', user.id);
    return user;
  }

  // ── Sign in ───────────────────────────────────────────────────

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _db.getUserByEmail(email);
    if (user == null) {
      throw Exception('No account found with this email.');
    }
    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Incorrect password.');
    }
    await _db.setSetting('current_user_id', user.id);
    return user;
  }

  // ── Sign out ──────────────────────────────────────────────────

  Future<void> signOut() async {
    await _db.setSetting('current_user_id', '');
  }

  // ── Session restore ───────────────────────────────────────────

  Future<User?> getSignedInUser() async {
    final id = await _db.getSetting('current_user_id');
    if (id == null || id.isEmpty) return null;
    return _db.getUserById(id);
  }

  // ── Profile update ────────────────────────────────────────────

  Future<User> updateProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    final user = await _db.getUserById(userId);
    if (user == null) throw Exception('User not found.');

    final updated = user.copyWith(name: name, email: email);
    await _db.updateUser(updated);
    return updated;
  }
}
