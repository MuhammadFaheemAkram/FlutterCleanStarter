import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:intl/intl.dart';

/// How the app writes a day: "today", "tomorrow", "yesterday", or
/// "Thu 29 Oct", with the year only when it isn't [today]'s ("Fri 1 Jan
/// 2027").
///
/// Lower case, to sit inside a sentence ("Due today"); a label that starts
/// with it capitalizes it ([capitalized]).
String dayLabel(CalendarDate day, {required CalendarDate today}) {
  switch (today.daysUntil(day)) {
    case 0:
      return 'today';
    case 1:
      return 'tomorrow';
    case -1:
      return 'yesterday';
  }
  final pattern = day.year == today.year ? 'EEE d MMM' : 'EEE d MMM y';
  return DateFormat(pattern).format(day.toDateTime());
}

/// The day of [instant] on the device's clock: "20 Jul", with the year
/// when it isn't [today]'s ("20 Jul 2025").
String shortDate(DateTime instant, {required CalendarDate today}) {
  final local = instant.toLocal();
  final pattern = local.year == today.year ? 'd MMM' : 'd MMM y';
  return DateFormat(pattern).format(local);
}

/// [text] with its first letter in upper case.
String capitalized(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
