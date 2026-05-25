import '../models/transaction.dart';
import '../services/local_db_service.dart';

class TransactionRepository {
  final LocalDbService _db;
  TransactionRepository(this._db);

  Future<void> add(Transaction t) => _db.insertTransaction(t);
  Future<void> addAll(List<Transaction> list) => _db.insertTransactions(list);
  Future<void> update(Transaction t) => _db.updateTransaction(t);
  Future<void> delete(String id) => _db.deleteTransaction(id);
  Future<void> clearAll() => _db.deleteAllTransactions();
  Future<List<Transaction>> getAll() => _db.getAllTransactions();
  Future<List<Transaction>> getByMonth(int year, int month) =>
      _db.getTransactionsByMonth(year, month);
  Future<List<Transaction>> getLastNDays(int days) =>
      _db.getTransactionsLastNDays(days);
}
