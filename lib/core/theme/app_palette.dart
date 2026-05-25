import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color navBar;

  final Color primary;
  final Color primaryLight;
  final Color primaryText;

  final Color income;
  final Color incomeLight;
  final Color incomeText;

  final Color expense;
  final Color expenseLight;
  final Color expenseText;

  final Color textPrimary;
  final Color textSecondary;

  final Color alertBg;
  final Color alertBorder;

  final Color cardBorder;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.navBar,
    required this.primary,
    required this.primaryLight,
    required this.primaryText,
    required this.income,
    required this.incomeLight,
    required this.incomeText,
    required this.expense,
    required this.expenseLight,
    required this.expenseText,
    required this.textPrimary,
    required this.textSecondary,
    required this.alertBg,
    required this.alertBorder,
    required this.cardBorder,
  });

  const AppPalette.light()
      : background = const Color(0xFFF7F4EF),
        surface = const Color(0xFFFFFFFF),
        navBar = const Color(0xFFF7F4EF),
        primary = const Color(0xFF5C6BC0),
        primaryLight = const Color(0x1A5C6BC0),
        primaryText = const Color(0xFF4352A5),
        income = const Color(0xFF81C784),
        incomeLight = const Color(0x1A81C784),
        incomeText = const Color(0xFF286B33),
        expense = const Color(0xFFE57373),
        expenseLight = const Color(0x1AE57373),
        expenseText = const Color(0xFF98393B),
        textPrimary = const Color(0xFF1A1A2B),
        textSecondary = const Color(0xFF767683),
        alertBg = const Color(0x1A5C6BC0),
        alertBorder = const Color(0x335C6BC0),
        cardBorder = const Color(0xFFE2E0F8);

  const AppPalette.dark()
      : background = const Color(0xFF11131C),
        surface = const Color(0xFF1B1E2A),
        navBar = const Color(0xFF141826),
        primary = const Color(0xFF8FA1FF),
        primaryLight = const Color(0x2A8FA1FF),
        primaryText = const Color(0xFFD6DBFF),
        income = const Color(0xFF81C784),
        incomeLight = const Color(0x2681C784),
        incomeText = const Color(0xFFAEDFB3),
        expense = const Color(0xFFE57373),
        expenseLight = const Color(0x26E57373),
        expenseText = const Color(0xFFF2B0B0),
        textPrimary = const Color(0xFFF2F3FF),
        textSecondary = const Color(0xFF9A9FB3),
        alertBg = const Color(0x268FA1FF),
        alertBorder = const Color(0x448FA1FF),
        cardBorder = const Color(0xFF2A2E3E);

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? navBar,
    Color? primary,
    Color? primaryLight,
    Color? primaryText,
    Color? income,
    Color? incomeLight,
    Color? incomeText,
    Color? expense,
    Color? expenseLight,
    Color? expenseText,
    Color? textPrimary,
    Color? textSecondary,
    Color? alertBg,
    Color? alertBorder,
    Color? cardBorder,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      navBar: navBar ?? this.navBar,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryText: primaryText ?? this.primaryText,
      income: income ?? this.income,
      incomeLight: incomeLight ?? this.incomeLight,
      incomeText: incomeText ?? this.incomeText,
      expense: expense ?? this.expense,
      expenseLight: expenseLight ?? this.expenseLight,
      expenseText: expenseText ?? this.expenseText,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      alertBg: alertBg ?? this.alertBg,
      alertBorder: alertBorder ?? this.alertBorder,
      cardBorder: cardBorder ?? this.cardBorder,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      navBar: Color.lerp(navBar, other.navBar, t) ?? navBar,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t) ?? primaryLight,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
      income: Color.lerp(income, other.income, t) ?? income,
      incomeLight: Color.lerp(incomeLight, other.incomeLight, t) ?? incomeLight,
      incomeText: Color.lerp(incomeText, other.incomeText, t) ?? incomeText,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      expenseLight: Color.lerp(expenseLight, other.expenseLight, t) ?? expenseLight,
      expenseText: Color.lerp(expenseText, other.expenseText, t) ?? expenseText,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      alertBg: Color.lerp(alertBg, other.alertBg, t) ?? alertBg,
      alertBorder: Color.lerp(alertBorder, other.alertBorder, t) ?? alertBorder,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t) ?? cardBorder,
    );
  }
}
