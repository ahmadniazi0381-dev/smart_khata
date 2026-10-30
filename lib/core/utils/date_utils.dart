import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _timeFormat = DateFormat('hh:mm a');

  /// Now as UTC epoch milliseconds
  static int nowMs() => DateTime.now().millisecondsSinceEpoch;

  /// Convert epoch ms to local DateTime
  static DateTime fromMs(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: false);

  /// Format for display: "30 Oct 2026"
  static String formatDate(int ms) => _dateFormat.format(fromMs(ms));

  /// Format with time: "30 Oct 2026, 10:30 PM"
  static String formatDateTime(int ms) => _dateTimeFormat.format(fromMs(ms));

  /// Format time only: "10:30 PM"
  static String formatTime(int ms) => _timeFormat.format(fromMs(ms));

  /// Start of today (local) as epoch ms
  static int startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  /// End of today (local) as epoch ms
  static int endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;
  }

  /// Start of given date
  static int startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  /// End of given date
  static int endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;
}
