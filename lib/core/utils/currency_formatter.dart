import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol${formatter.format(amount.abs())}';
  }

  static String formatWithSign(double amount, {String symbol = '\$'}) {
    final formatted = format(amount, symbol: symbol);
    return amount >= 0 ? '+$formatted' : '-$formatted';
  }
}
