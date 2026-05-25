import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SettingsRepository _settings;

  ThemeCubit(this._settings, ThemeMode initial) : super(initial);

  Future<void> setLight() async {
    await _settings.set('theme_mode', 'light');
    emit(ThemeMode.light);
  }

  Future<void> setDark() async {
    await _settings.set('theme_mode', 'dark');
    emit(ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (mode == ThemeMode.dark) {
      await setDark();
    } else {
      await setLight();
    }
  }

  Future<void> toggle() async {
    state == ThemeMode.light ? await setDark() : await setLight();
  }

  bool get isDark => state == ThemeMode.dark;
}
