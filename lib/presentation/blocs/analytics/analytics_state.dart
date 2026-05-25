import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart';
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override List<Object?> get props => [];
}
class AnalyticsInitial extends AnalyticsState { const AnalyticsInitial(); }
class AnalyticsLoading extends AnalyticsState { const AnalyticsLoading(); }
class AnalyticsLoaded  extends AnalyticsState {
  final Map<TransactionCategory, double> categoryBreakdown;
  final List<double> monthlyTotals;
  const AnalyticsLoaded({required this.categoryBreakdown, required this.monthlyTotals});
  @override List<Object?> get props => [categoryBreakdown, monthlyTotals];
}
class AnalyticsError   extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override List<Object?> get props => [message];
}
