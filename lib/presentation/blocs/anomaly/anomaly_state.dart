import 'package:equatable/equatable.dart';
import '../../../data/models/anomaly_result.dart';
abstract class AnomalyState extends Equatable {
  const AnomalyState();
  @override List<Object?> get props => [];
}
class AnomalyInitial   extends AnomalyState { const AnomalyInitial(); }
class AnomalyChecking  extends AnomalyState { const AnomalyChecking(); }
class AnomalyDetected  extends AnomalyState {
  final AnomalyResult result;
  const AnomalyDetected(this.result);
  @override List<Object?> get props => [result];
}
class AnomalyNone      extends AnomalyState { const AnomalyNone(); }
class AnomalyDismissed extends AnomalyState { const AnomalyDismissed(); }
class AnomalyError     extends AnomalyState {
  final String message;
  const AnomalyError(this.message);
  @override List<Object?> get props => [message];
}
