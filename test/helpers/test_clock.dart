import 'package:flutter_clean_starter/domain/model/calendar_date.dart';

/// "Now" in every test: Wednesday 28 October 2026, 14:00 UTC.
final demoNow = DateTime.utc(2026, 10, 28, 14);

/// The day of [demoNow]: the tests' "today".
final demoToday = CalendarDate(2026, 10, 28);
