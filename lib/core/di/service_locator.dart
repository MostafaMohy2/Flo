import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/services/local_db_service.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/ocr_service.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/ai_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../presentation/blocs/transactions/transactions_bloc.dart';
import '../../presentation/blocs/ai_chat/ai_chat_bloc.dart';
import '../../presentation/blocs/anomaly/anomaly_bloc.dart';
import '../../presentation/blocs/analytics/analytics_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';

/// Global service locator instance — import [sl] wherever you need to resolve a dependency.
final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── External ──────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      ));

  // ── Services ──────────────────────────────────────────────────
  sl.registerLazySingleton<LocalDbService>(() => LocalDbService());

  sl.registerLazySingleton<AiService>(() => AiService(
        apiKey: dotenv.env['GROQ_API_KEY'] ?? '',
        dio: sl<Dio>(),
      ));

  sl.registerLazySingleton<OcrService>(() => OcrService());

  // ── Repositories ──────────────────────────────────────────────
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(sl<LocalDbService>()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(sl<LocalDbService>()),
  );

  sl.registerLazySingleton<AiRepository>(
    () => AiRepository(sl<AiService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<LocalDbService>()),
  );

  // ── Blocs ─────────────────────────────────────────────────────
  // AuthBloc is a singleton — one instance lives at the app root
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

  // App blocs are factories — fresh instance per BlocProvider
  sl.registerFactory<TransactionsBloc>(
    () => TransactionsBloc(sl<TransactionRepository>()),
  );

  sl.registerFactory<AiChatBloc>(
    () => AiChatBloc(
      aiRepo: sl<AiRepository>(),
      txRepo: sl<TransactionRepository>(),
    ),
  );

  sl.registerFactory<AnomalyBloc>(
    () => AnomalyBloc(
      aiRepo:   sl<AiRepository>(),
      txRepo:   sl<TransactionRepository>(),
      settings: sl<SettingsRepository>(),
    ),
  );

  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(sl<TransactionRepository>()),
  );
}
