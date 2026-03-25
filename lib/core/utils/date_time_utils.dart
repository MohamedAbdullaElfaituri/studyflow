import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String friendlyDate(DateTime dateTime, String locale) {
    return DateFormat.yMMMd(locale).format(dateTime);
  }

  static String weekdayShort(DateTime dateTime, String locale) {
    return DateFormat.E(locale).format(dateTime);
  }

  static String time(DateTime dateTime, String locale) {
    return DateFormat.Hm(locale).format(dateTime);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
