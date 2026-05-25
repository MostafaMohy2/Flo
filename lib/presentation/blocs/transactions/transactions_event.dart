import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();
  @override List<Object?> get props => [];
}

class LoadTransactions      extends TransactionsEvent { const LoadTransactions(); }
class LoadTransactionsByMonth extends TransactionsEvent {
  final int year, month;
  const LoadTransactionsByMonth(this.year, this.month);
  @override List<Object?> get props => [year, month];
}
class AddTransaction        extends TransactionsEvent {
  final Transaction transaction;
  const AddTransaction(this.transaction);
  @override List<Object?> get props => [transaction];
}
class UpdateTransaction     extends TransactionsEvent {
  final Transaction transaction;
  const UpdateTransaction(this.transaction);
  @override List<Object?> get props => [transaction];
}
class DeleteTransaction     extends TransactionsEvent {
  final String id;
  const DeleteTransaction(this.id);
  @override List<Object?> get props => [id];
}

class ClearTransactions extends TransactionsEvent {
  const ClearTransactions();
}

class UndoClearTransactions extends TransactionsEvent {
  const UndoClearTransactions();
}
