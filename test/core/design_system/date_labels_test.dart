import 'package:flutter_clean_starter/core/design_system/date_labels.dart';
import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = CalendarDate(2026, 10, 28);

  group('dayLabel', () {
    test('names the days next to today', () {
      expect(dayLabel(today, today: today), 'today');
      expect(dayLabel(today.addDays(1), today: today), 'tomorrow');
      expect(dayLabel(today.addDays(-1), today: today), 'yesterday');
    });

    test('other days of this year: the weekday, day and month', () {
      expect(dayLabel(today.addDays(2), today: today), 'Fri 30 Oct');
      expect(dayLabel(CalendarDate(2026, 1, 5), today: today), 'Mon 5 Jan');
    });

    test('another year adds the year', () {
      expect(
        dayLabel(CalendarDate(2027, 1, 1), today: today),
        'Fri 1 Jan 2027',
      );
      expect(
        dayLabel(CalendarDate(2025, 12, 31), today: today),
        'Wed 31 Dec 2025',
      );
    });
  });

  test("shortDate: the instant's day on the device, the year when another", () {
    // Midday UTC is the same day in every zone from UTC−11 to UTC+11.
    expect(shortDate(DateTime.utc(2026, 7, 20, 12), today: today), '20 Jul');
    expect(
      shortDate(DateTime.utc(2025, 7, 20, 12), today: today),
      '20 Jul 2025',
    );
  });

  test('capitalized', () {
    expect(capitalized('today'), 'Today');
    expect(capitalized(''), '');
  });

  test('longDayLabel: the day in full', () {
    expect(
      longDayLabel(CalendarDate(2026, 10, 29)),
      'Thursday 29 October 2026',
    );
  });

  test("dateTimeLabel: the day and the time, on the device's clock", () {
    final instant = DateTime(2026, 7, 20, 14, 5).toUtc();

    expect(dateTimeLabel(instant, use24HourFormat: true), '20 Jul 2026, 14:05');
    expect(
      dateTimeLabel(instant, use24HourFormat: false),
      matches(RegExp(r'^20 Jul 2026, 2:05\sPM$')),
    );
  });
}
