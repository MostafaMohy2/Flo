import 'package:equatable/equatable.dart';
abstract class AnomalyEvent extends Equatable {
  const AnomalyEvent();
  @override List<Object?> get props => [];
}
class CheckAnomalies  extends AnomalyEvent { const CheckAnomalies(); }
class DismissAnomaly  extends AnomalyEvent { const DismissAnomaly(); }
