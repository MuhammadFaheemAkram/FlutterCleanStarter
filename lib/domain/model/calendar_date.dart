/// A day on the calendar, with no time and no time zone: 29 October 2026 is
/// `20261029`.
///
/// A task's due date is a *day*, not an instant: "due Thursday" means
/// Thursday wherever the user is, and must not become Wednesday after a
/// flight west. Storing a `DateTime` would tie the day to a time zone. A
/// `yyyymmdd` integer sorts and compares like the dates it stands for, and
/// makes a range a plain `BETWEEN` in SQL.
///
/// An extension type over `int`, so it costs nothing at runtime. The private
/// representation constructor means every value goes through a factory that
/// checks it is a real date.
extension type const CalendarDate._(int yyyymmdd) {
  /// The day [year]-[month]-[day]. Throws an [ArgumentError] for a date that
  /// doesn't exist (31 April, 29 February 2027).
  factory CalendarDate(int year, int month, int day) {
    if (year < 1 ||
        year > 9999 ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > daysInMonth(year, month)) {
      throw ArgumentError('Not a date: $year-$month-$day');
    }
    return CalendarDate._(year * 10000 + month * 100 + day);
  }

  /// The day a stored `yyyymmdd` integer stands for.
  factory CalendarDate.fromInt(int yyyymmdd) =>
      CalendarDate(yyyymmdd ~/ 10000, yyyymmdd ~/ 100 % 100, yyyymmdd % 100);

  /// The calendar day of [dateTime] *in its own time zone*: pass a local
  /// time (`clock.now()`) to get the user's "today".
  factory CalendarDate.fromDateTime(DateTime dateTime) =>
      CalendarDate(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `2026-10-29`. Throws a [FormatException] for anything else,
  /// including a date that doesn't exist.
  factory CalendarDate.parse(String iso) {
    final match = _isoPattern.firstMatch(iso);
    if (match == null) throw FormatException('Not a yyyy-MM-dd date', iso);
    try {
      return CalendarDate(
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
      );
    } on ArgumentError {
      throw FormatException('Not a date', iso);
    }
  }

  int get year => yyyymmdd ~/ 10000;

  int get month => yyyymmdd ~/ 100 % 100;

  int get day => yyyymmdd % 100;

  /// 1 (Monday) to 7 (Sunday), as `DateTime.weekday`.
  int get weekday => _utc.weekday;

  /// [days] later (or earlier, when negative). Computed in UTC, which has no
  /// daylight-saving jumps, so adding a day is always exactly one day.
  CalendarDate addDays(int days) =>
      CalendarDate.fromDateTime(_utc.add(Duration(days: days)));

  /// The days from this one to [other], negative when [other] is earlier.
  int daysUntil(CalendarDate other) => other._utc.difference(_utc).inDays;

  bool operator <(CalendarDate other) => yyyymmdd < other.yyyymmdd;

  bool operator <=(CalendarDate other) => yyyymmdd <= other.yyyymmdd;

  bool operator >(CalendarDate other) => yyyymmdd > other.yyyymmdd;

  bool operator >=(CalendarDate other) => yyyymmdd >= other.yyyymmdd;

  /// Local midnight of this day, for formatting with `intl` or a date
  /// picker.
  DateTime toDateTime() => DateTime(year, month, day);

  /// `2026-10-29`.
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  DateTime get _utc => DateTime.utc(year, month, day);

  /// The number of days in [month] of [year] (leap years included).
  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  static final _isoPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
}
