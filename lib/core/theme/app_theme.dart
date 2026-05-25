import 'package:flutter/material.dart';
import 'app_text_styles.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const palette = AppPalette.light();
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'DMSans',
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        surface: palette.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.heading2(palette.textPrimary),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppTextStyles.bodyLarge(palette.textPrimary)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium(palette.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.navBar,
        selectedItemColor: palette.primaryText,
        unselectedItemColor: palette.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const [palette],
    );
  }

  static ThemeData get darkTheme {
    const palette = AppPalette.dark();
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'DMSans',
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        surface: palette.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.heading2(palette.textPrimary),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: AppTextStyles.bodyLarge(palette.textPrimary)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium(palette.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.navBar,
        selectedItemColor: palette.primaryText,
        unselectedItemColor: palette.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      extensions: const [palette],
    );
  }
}
