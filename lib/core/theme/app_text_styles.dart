import 'package:flutter/material.dart';
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'DMSans';

  static TextStyle heading1(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: color,
    letterSpacing: -0.24,
  );

  static TextStyle heading2(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle heading3(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodySmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
    letterSpacing: 0.48,
  );

  static TextStyle labelSmall(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: color,
  );

  static TextStyle balanceLarge(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle amountExpense(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle amountIncome(Color color) => TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
