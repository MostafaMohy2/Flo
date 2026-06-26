import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
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
  await EasyLocalization.ensureInitialized();

  // Initialize storage — Hive on web, no-op on mobile (sqflite opens lazily)
  await LocalDbService.ensureInit();

  await setupLocator();

  final settings    = sl<SettingsRepository>();
  final themeString = await settings.get('theme_mode') ?? 'light';
  final localeCode  = await settings.get('locale_code') ?? 'en';
  final themeMode   = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

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
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            builder: (ctx, child) {
              final screenWidth   = MediaQuery.of(ctx).size.width;
              final isLargeScreen = screenWidth > 480;

              final responsive = ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0,   end: 480,             name: MOBILE),
                  const Breakpoint(start: 481, end: 900,             name: TABLET),
                  const Breakpoint(start: 901, end: double.infinity, name: DESKTOP),
                ],
              );

              if (!isLargeScreen) return responsive;

              return ColoredBox(
                color: const Color(0xFFEDE9FF),
                child: Center(
                  child: SizedBox(
                    width: 430,
                    child: ClipRect(child: responsive),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
