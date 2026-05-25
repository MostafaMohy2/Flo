import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository _repo;
  List<Transaction> _lastCleared = const [];

  TransactionsBloc(this._repo) : super(const TransactionsInitial()) {
    on<LoadTransactions>(_onLoad);
    on<LoadTransactionsByMonth>(_onLoadByMonth);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
    on<ClearTransactions>(_onClearAll);
    on<UndoClearTransactions>(_onUndoClear);
  }

  Future<void> _onLoad(LoadTransactions event, Emitter emit) async {
    emit(const TransactionsLoading());
    try {
      final transactions = await _repo.getAll();
      emit(_toLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onLoadByMonth(LoadTransactionsByMonth event, Emitter emit) async {
    emit(const TransactionsLoading());
    try {
      final transactions = await _repo.getByMonth(event.year, event.month);
      emit(_toLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onAdd(AddTransaction event, Emitter emit) async {
    try {
      await _repo.add(event.transaction);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTransaction event, Emitter emit) async {
    try {
      await _repo.update(event.transaction);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTransaction event, Emitter emit) async {
    try {
      await _repo.delete(event.id);
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onClearAll(ClearTransactions event, Emitter emit) async {
    emit(const TransactionsLoading());
    try {
      final snapshot = await _repo.getAll();
      _lastCleared = snapshot;
      await _repo.clearAll();
      final transactions = await _repo.getAll();
      emit(_toLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onUndoClear(UndoClearTransactions event, Emitter emit) async {
    if (_lastCleared.isEmpty) return;
    emit(const TransactionsLoading());
    try {
      await _repo.addAll(_lastCleared);
      _lastCleared = const [];
      final transactions = await _repo.getAll();
      emit(_toLoaded(transactions));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  TransactionsLoaded _toLoaded(List<Transaction> list) {
    final income   = list.where((t) => t.type == TransactionType.income)
                        .fold(0.0, (s, t) => s + t.amount);
    final expenses = list.where((t) => t.type == TransactionType.expense)
                        .fold(0.0, (s, t) => s + t.amount);
    return TransactionsLoaded(
      transactions:  list,
      totalIncome:   income,
      totalExpenses: expenses,
      balance:       income - expenses,
    );
  }
}
