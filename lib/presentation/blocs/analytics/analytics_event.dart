import 'package:equatable/equatable.dart';
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override List<Object?> get props => [];
}
class LoadAnalytics extends AnalyticsEvent {
  final int year, month;
  const LoadAnalytics(this.year, this.month);
  @override List<Object?> get props => [year, month];
}
