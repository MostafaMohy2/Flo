import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/ai_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'anomaly_event.dart';
import 'anomaly_state.dart';

class AnomalyBloc extends Bloc<AnomalyEvent, AnomalyState> {
  final AiRepository _aiRepo;
  final TransactionRepository _txRepo;
  final SettingsRepository _settings;

  AnomalyBloc({
    required AiRepository aiRepo,
    required TransactionRepository txRepo,
    required SettingsRepository settings,
  })  : _aiRepo   = aiRepo,
        _txRepo   = txRepo,
        _settings = settings,
        super(const AnomalyInitial()) {
    on<CheckAnomalies>(_onCheck);
    on<DismissAnomaly>(_onDismiss);
  }

  Future<void> _onCheck(CheckAnomalies event, Emitter emit) async {
    // Only check once every 24 hours
    final lastCheck = await _settings.getLastAnomalyCheck();
    if (lastCheck != null &&
        DateTime.now().difference(lastCheck).inHours < 24) {
      return;
    }

    emit(const AnomalyChecking());
    try {
      final thisWeek     = await _txRepo.getLastNDays(7);
      final lastFourWeeks = await _txRepo.getLastNDays(28);
      final result       = await _aiRepo.checkAnomalies(
        thisWeek:      thisWeek,
        lastFourWeeks: lastFourWeeks,
      );

      await _settings.setLastAnomalyCheck(DateTime.now());

      if (result.hasAnomaly) {
        emit(AnomalyDetected(result));
      } else {
        emit(const AnomalyNone());
      }
    } catch (e) {
      emit(AnomalyError(e.toString()));
    }
  }

  void _onDismiss(DismissAnomaly event, Emitter emit) =>
      emit(const AnomalyDismissed());
}
