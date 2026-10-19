import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/time/time.dart';

void main() {
  group('Core Time Functions & Models (SSOT Verification)', () {
    test('normalizeToCalendarDate strips hours, minutes, and seconds', () {
      final DateTime dt = DateTime(2026, 10, 22, 18, 45, 30);
      final DateTime normalized = normalizeToCalendarDate(dt);

      expect(normalized.year, equals(2026));
      expect(normalized.month, equals(10));
      expect(normalized.day, equals(22));
      expect(normalized.hour, equals(0));
      expect(normalized.minute, equals(0));
      expect(normalized.second, equals(0));
      expect(normalized.millisecond, equals(0));
    });

    test('calculateInclusiveDayCount strictly conforms to backend inclusive arithmetic', () {
      final DateTime start = DateTime(2026, 10, 22, 18, 10);
      final DateTime sameDay = DateTime(2026, 10, 22, 8, 30);
      final DateTime nextDay = DateTime(2026, 10, 23, 7, 0);
      final DateTime threeDays = DateTime(2026, 10, 24, 23, 59);

      // Same day = 1 day
      expect(calculateInclusiveDayCount(start, sameDay), equals(1));
      // 22 Oct to 23 Oct = exactly 2 days (fixing the old fractional-hour bug)
      expect(calculateInclusiveDayCount(start, nextDay), equals(2));
      // 22 Oct to 24 Oct = 3 days
      expect(calculateInclusiveDayCount(start, threeDays), equals(3));
    });

    test('CalendarDateRange encapsulates normalized boundaries and duration', () {
      final CalendarDateRange range = CalendarDateRange(
        start: DateTime(2026, 10, 22, 14, 0),
        end: DateTime(2026, 10, 23, 9, 0),
      );

      expect(range.durationDays, equals(2));
      expect(range.isSingleDay, isFalse);
      expect(range.contains(DateTime(2026, 10, 22)), isTrue);
      expect(range.contains(DateTime(2026, 10, 23)), isTrue);
      expect(range.contains(DateTime(2026, 10, 24)), isFalse);

      expect(
        () => CalendarDateRange(
          start: DateTime(2026, 10, 23),
          end: DateTime(2026, 10, 22),
        ),
        throwsArgumentError,
      );
    });

    test('formatIsoDateString and parseIsoDateString handle canonical ISO formats', () {
      final DateTime dt = DateTime(2026, 10, 22);
      final String isoStr = formatIsoDateString(dt);
      expect(isoStr, equals('2026-10-22'));

      final DateTime? parsed = parseIsoDateString('2026-10-22');
      expect(parsed, isNotNull);
      expect(parsed!.year, equals(2026));
      expect(parsed.month, equals(10));
      expect(parsed.day, equals(22));

      expect(parseIsoDateString('invalid-date'), isNull);
      expect(parseIsoDateString(null), isNull);
    });

    test('formatLocalizedDate produces correct Indonesian dates based on style', () {
      final DateTime dt = DateTime(2026, 10, 22); // Thursday / Kamis

      expect(
        formatLocalizedDate(dt, style: 'human_full'),
        equals('Kamis, 22 Oktober 2026'),
      );
      expect(
        formatLocalizedDate(dt, style: 'human_short'),
        equals('22 Okt 2026'),
      );
      expect(
        formatLocalizedDate(dt, style: 'day_and_short_month'),
        equals('Kamis, 22 Okt'),
      );
      expect(
        formatLocalizedDate(dt, style: 'iso'),
        equals('2026-10-22'),
      );
    });

    test('formatLocalizedTime formats 24h and 12h accurately', () {
      final DateTime dt = DateTime(2026, 10, 22, 18, 5);

      expect(formatLocalizedTime(dt, style: '24h'), equals('18:05'));
      expect(formatLocalizedTime(dt, style: '12h'), equals('06:05 PM'));
    });

    test('calculateOvertimeMinutes respects clinic late tolerance and enabled flag', () {
      final DateTime scheduledEnd = DateTime(2026, 10, 22, 18, 0);

      // 10 minutes late (within 15 min tolerance) -> 0 overtime (human error buffer)
      final DateTime lateCheckout10Min = DateTime(2026, 10, 22, 18, 10);
      expect(
        calculateOvertimeMinutes(
          scheduledEnd: scheduledEnd,
          actualCheckOut: lateCheckout10Min,
        ),
        equals(0),
      );

      // 15 minutes late (exact tolerance) -> 0 overtime
      final DateTime lateCheckout15Min = DateTime(2026, 10, 22, 18, 15);
      expect(
        calculateOvertimeMinutes(
          scheduledEnd: scheduledEnd,
          actualCheckOut: lateCheckout15Min,
        ),
        equals(0),
      );

      // 45 minutes late -> 45 minutes overtime
      final DateTime lateCheckout45Min = DateTime(2026, 10, 22, 18, 45);
      expect(
        calculateOvertimeMinutes(
          scheduledEnd: scheduledEnd,
          actualCheckOut: lateCheckout45Min,
        ),
        equals(45),
      );

      // Overtime disabled in config -> always 0
      const ClinicAttendanceTimeConfig disabledConfig =
          ClinicAttendanceTimeConfig(
        checkInWindowMinutesBefore: 60,
        checkInWindowMinutesAfter: 30,
        lateToleranceMinutes: 15,
        qrRotationSeconds: 30,
        overtimeEnabled: false,
      );
      expect(
        calculateOvertimeMinutes(
          scheduledEnd: scheduledEnd,
          actualCheckOut: lateCheckout45Min,
          config: disabledConfig,
        ),
        equals(0),
      );
    });

    test('isWithinToleranceWindow validates check-in range', () {
      final DateTime scheduledStart = DateTime(2026, 10, 22, 8, 0);
      final DateTime scheduledEnd = DateTime(2026, 10, 22, 14, 0);

      // Check-in window before is 60 min -> 07:00
      // Check-in window after is 30 min -> 14:30
      expect(
        isWithinToleranceWindow(
          timestamp: DateTime(2026, 10, 22, 7, 15),
          scheduledStart: scheduledStart,
          scheduledEnd: scheduledEnd,
        ),
        isTrue,
      );
      expect(
        isWithinToleranceWindow(
          timestamp: DateTime(2026, 10, 22, 6, 50),
          scheduledStart: scheduledStart,
          scheduledEnd: scheduledEnd,
        ),
        isFalse,
      );
    });

    test('TimeOfDayRange parses and checks time windows', () {
      const TimeOfDayRange range = TimeOfDayRange(
        startTime: '08:00',
        endTime: '14:00',
      );

      expect(range.startMinutes, equals(480));
      expect(range.endMinutes, equals(840));
      expect(range.durationMinutes, equals(360)); // 6 hours

      expect(range.containsTime(DateTime(2026, 10, 22, 10, 30)), isTrue);
      expect(range.containsTime(DateTime(2026, 10, 22, 16, 0)), isFalse);
    });

    test('DefaultTimeService integrates configuration, formatting, and calculations', () {
      final DefaultTimeConfigProvider configProvider =
          DefaultTimeConfigProvider();
      final DefaultTimeService service =
          DefaultTimeService(configProvider: configProvider);

      expect(service.config.timezone, equals('Asia/Jakarta'));
      expect(service.config.locale, equals('id-ID'));

      final DateTime start = DateTime(2026, 10, 22);
      final DateTime end = DateTime(2026, 10, 23);

      expect(service.calculateDays(start, end), equals(2));
      expect(
        service.formatDateRange(start, end),
        equals('22 Okt 2026 — 23 Okt 2026'),
      );
      expect(
        service.formatDate(start),
        equals('Kamis, 22 Oktober 2026'),
      );

      // Dynamic config update test
      configProvider.updateConfig(
        service.config.copyWith(dateFormatStyle: 'human_short'),
      );
      expect(service.formatDate(start), equals('22 Okt 2026'));
    });
  });
}
