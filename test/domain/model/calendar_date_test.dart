import 'package:flutter_clean_starter/domain/model/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores a day as yyyymmdd, and reads its parts back', () {
    final day = CalendarDate(2026, 10, 29);

    expect(day.yyyymmdd, 20261029);
    expect((day.year, day.month, day.day), (2026, 10, 29));
    expect(day.weekday, DateTime.thursday);
  });

  test('refuses dates that do not exist', () {
    expect(() => CalendarDate(2026, 4, 31), throwsArgumentError);
    expect(() => CalendarDate(2027, 2, 29), throwsArgumentError);
    expect(() => CalendarDate(2026, 13, 1), throwsArgumentError);
    expect(() => CalendarDate(2026, 1, 0), throwsArgumentError);
    expect(CalendarDate(2028, 2, 29).day, 29);
  });

  test('round-trips through its int and its ISO text', () {
    final day = CalendarDate(2026, 3, 7);

    expect(CalendarDate.fromInt(day.yyyymmdd), day);
    expect(day.toIso(), '2026-03-07');
    expect(CalendarDate.parse('2026-03-07'), day);
  });

  test('parse refuses anything but a real yyyy-MM-dd day', () {
    for (final text in [
      '2026-3-7',
      '07/03/2026',
      '2026-03-07T00:00:00Z',
      '2026-02-30',
      '',
    ]) {
      expect(
        () => CalendarDate.parse(text),
        throwsFormatException,
        reason: text,
      );
    }
  });

  test('takes the day of a DateTime in its own zone', () {
    expect(
      CalendarDate.fromDateTime(DateTime.utc(2026, 10, 28, 23, 59)),
      CalendarDate(2026, 10, 28),
    );
    expect(
      CalendarDate.fromDateTime(DateTime(2026, 10, 29, 0, 1)),
      CalendarDate(2026, 10, 29),
    );
  });

  test('adds days across months, years and clock changes', () {
    // London's clocks went back on 25 October 2026: still one day.
    expect(CalendarDate(2026, 10, 24).addDays(1), CalendarDate(2026, 10, 25));
    expect(CalendarDate(2026, 10, 25).addDays(1), CalendarDate(2026, 10, 26));
    expect(CalendarDate(2026, 12, 31).addDays(1), CalendarDate(2027, 1, 1));
    expect(CalendarDate(2026, 3, 1).addDays(-1), CalendarDate(2026, 2, 28));
  });

  test('counts the days between two days', () {
    final day = CalendarDate(2026, 10, 28);

    expect(day.daysUntil(CalendarDate(2026, 11, 4)), 7);
    expect(day.daysUntil(CalendarDate(2026, 10, 27)), -1);
    expect(day.daysUntil(day), 0);
  });

  test('compares like the dates it stands for', () {
    final earlier = CalendarDate(2026, 9, 30);
    final later = CalendarDate(2026, 10, 1);

    expect(earlier < later, isTrue);
    expect(earlier <= earlier, isTrue);
    expect(later > earlier, isTrue);
    expect(later >= later, isTrue);
    expect(earlier > later, isFalse);
  });

  test('is local midnight as a DateTime', () {
    expect(CalendarDate(2026, 10, 29).toDateTime(), DateTime(2026, 10, 29));
  });
}
