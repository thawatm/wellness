import 'package:intl/intl.dart';

String socialDate(DateTime tm) {
  DateTime today = DateTime.now();

  today = DateTime(today.year, today.month, today.day);
  tm = DateTime(tm.year, tm.month, tm.day);

  Duration oneDay = Duration(days: 0);
  Duration twoDay = Duration(days: 1);
  Duration oneWeek = Duration(days: 6);

  Duration difference = today.difference(tm);
  if (difference.isNegative) return DateFormat('E MMMM d').format(tm);

  if (difference.compareTo(oneDay) == 0) {
    return "Today";
  } else if (difference.compareTo(twoDay) == 0) {
    return "Yesterday";
  } else if (difference.compareTo(oneWeek) < 1) {
    return DateFormat('EEEE').format(tm);
  } else if (tm.year == today.year) {
    return DateFormat('MMMM d').format(tm);
  } else {
    return DateFormat('d MMMM yyyy').format(tm);
  }
}
