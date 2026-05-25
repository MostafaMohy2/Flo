import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();
  @override List<Object?> get props => [];
}

class TransactionsInitial  extends TransactionsState { const TransactionsInitial(); }
class TransactionsLoading  extends TransactionsState { const TransactionsLoading(); }
class TransactionsLoaded   extends TransactionsState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpenses;
  final double balance;

  const TransactionsLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
  });

  @override List<Object?> get props => [transactions, totalIncome, totalExpenses, balance];
}
class TransactionsError    extends TransactionsState {
  final String message;
  const TransactionsError(this.message);
  @override List<Object?> get props => [message];
}
