import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final TransactionRepository _repo;

  AnalyticsBloc(this._repo) : super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoad);
  }

  Future<void> _onLoad(LoadAnalytics event, Emitter emit) async {
    emit(const AnalyticsLoading());
    try {
      final transactions = await _repo.getByMonth(event.year, event.month);

      // Only expense-type transactions — income should never appear in
      // spending analytics. Also exclude the "income" category as a
      // belt-and-suspenders guard against mis-categorised transactions.
      final expenses = transactions.where((t) =>
          t.type == TransactionType.expense &&
          t.category != TransactionCategory.income).toList();

      final breakdown = <TransactionCategory, double>{};
      for (final t in expenses) {
        breakdown[t.category] = (breakdown[t.category] ?? 0) + t.amount;
      }

      // Last 6 months expense totals for the bar chart
      final monthlyTotals = <double>[];
      for (int i = 5; i >= 0; i--) {
        final d    = DateTime(event.year, event.month - i, 1);
        final list = await _repo.getByMonth(d.year, d.month);
        monthlyTotals.add(list
            .where((t) =>
                t.type == TransactionType.expense &&
                t.category != TransactionCategory.income)
            .fold(0.0, (s, t) => s + t.amount));
      }

      emit(AnalyticsLoaded(
          categoryBreakdown: breakdown, monthlyTotals: monthlyTotals));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
