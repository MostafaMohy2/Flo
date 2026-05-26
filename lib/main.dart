import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'data/services/local_db_service.dart';
import 'data/repositories/settings_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive works on web + mobile — no platform conditionals needed
  await LocalDbService.init();

  await EasyLocalization.ensureInitialized();

  // .env may not exist in web builds — load safely
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore — API key will be empty; app still runs
  }

  await setupLocator();

  final settings     = sl<SettingsRepository>();
  final themeString  = await settings.get('theme_mode') ?? 'light';
  final localeCode   = await settings.get('locale_code') ?? 'en';
  final themeMode    = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: Locale(localeCode),
        child: FloApp(initialThemeMode: themeMode),
      ),
    ),
  );
}

class FloApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const FloApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>()..add(const AppStarted()),
        ),
        BlocProvider(
          create: (_) =>
              ThemeCubit(sl<SettingsRepository>(), initialThemeMode),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'app.title'.tr(),
            debugShowCheckedModeBanner: false,
            builder: DevicePreview.appBuilder,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: DevicePreview.locale(context) ?? context.locale,
          );
        },
      ),
    );
  }
}
