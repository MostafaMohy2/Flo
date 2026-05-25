import 'package:equatable/equatable.dart';

class AnomalyResult extends Equatable {
  final bool hasAnomaly;
  final String? category;
  final double? currentWeekAmount;
  final double? averageWeekAmount;
  final double? percentageIncrease;
  final String? message;

  const AnomalyResult({
    required this.hasAnomaly,
    this.category,
    this.currentWeekAmount,
    this.averageWeekAmount,
    this.percentageIncrease,
    this.message,
  });

  factory AnomalyResult.none() => const AnomalyResult(hasAnomaly: false);

  factory AnomalyResult.fromJson(Map<String, dynamic> json) => AnomalyResult(
    hasAnomaly:         json['has_anomaly'] ?? false,
    category:           json['category'],
    currentWeekAmount:  (json['current_week_amount'] as num?)?.toDouble(),
    averageWeekAmount:  (json['average_week_amount'] as num?)?.toDouble(),
    percentageIncrease: (json['percentage_increase'] as num?)?.toDouble(),
    message:            json['message'],
  );

  @override
  List<Object?> get props => [hasAnomaly, category, currentWeekAmount, averageWeekAmount, percentageIncrease, message];
}
