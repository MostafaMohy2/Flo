import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String toDisplay(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String toMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String toShort(DateTime date) =>
      DateFormat('MMM d').format(date);
}
