import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'data/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/theme/theme_cubit.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await setupLocator();
  final settings = sl<SettingsRepository>();
  final themeMode = (await settings.get('theme_mode')) == 'dark'
      ? ThemeMode.dark
      : ThemeMode.light;
  final localeCode = (await settings.get('locale_code')) == 'ar' ? 'ar' : 'en';

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: Locale(localeCode),
      child: FloApp(initialThemeMode: themeMode),
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
        // AuthBloc lives at the very root — above MaterialApp so it
        // persists across all navigation and screen transitions.
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AppStarted())),
        BlocProvider(
          create: (_) => ThemeCubit(sl<SettingsRepository>(), initialThemeMode),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'app.title'.tr(),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          );
        },
      ),
    );
  }
}
