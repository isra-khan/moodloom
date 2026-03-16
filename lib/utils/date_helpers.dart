import 'package:intl/intl.dart';

class DateHelpers {
  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);
  static String formatDateTime(DateTime date) => DateFormat('MMM d, yyyy h:mm a').format(date);
  static String formatDayOfWeek(DateTime date) => DateFormat('EEEE').format(date);
  static String formatShortDay(DateTime date) => DateFormat('EEE').format(date);
  static String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);

  static DateTime startOfWeek(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return startOfDay(date.subtract(Duration(days: diff)));
  }

  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return endOfDay(start.add(const Duration(days: 6)));
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static List<DateTime> getDaysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      last.day,
      (i) => DateTime(first.year, first.month, i + 1),
    );
  }

  static int daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;
}
