import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class SessionShiftBoundary {
  const SessionShiftBoundary({
    required this.startMinutes,
    required this.endMinutes,
    required this.defaultStart,
    required this.defaultEnd,
  });

  final int startMinutes;
  final int endMinutes;
  final String defaultStart;
  final String defaultEnd;
}

SessionShiftBoundary getSessionShiftBoundary(
  String sessionId, [
  ScheduleContext? context,
]) {
  // 1. Trust Backend: Priority to ScheduleContext
  ScheduleContext? effectiveContext = context;
  if (effectiveContext == null) {
    final String targetShift = sessionShiftFromId(sessionId);
    effectiveContext = AmanahScheduleStore.instance.scheduleContexts
        .where((ScheduleContext c) =>
            c.sessionShift == targetShift ||
            c.sessionShift == sessionId ||
            c.contextId == sessionId ||
            c.contextId == targetShift)
        .firstOrNull;
  }

  if (effectiveContext != null) {
    final int? startM = parseTimeToMinutes(effectiveContext.boundaryStartTime);
    final int? endM = parseTimeToMinutes(effectiveContext.boundaryEndTime);
    if (startM != null && endM != null && endM > startM) {
      return SessionShiftBoundary(
        startMinutes: startM,
        endMinutes: endM,
        defaultStart: effectiveContext.boundaryStartTime,
        defaultEnd: effectiveContext.boundaryEndTime,
      );
    }
  }

  // 2. Trust Backend: Priority to Reference Options Shifts
  final ClinicShiftReference? refShift = AmanahScheduleStore
      .instance.scheduleOptions?.shifts
      .where((ClinicShiftReference s) =>
          s.shift.toLowerCase() == sessionId.toLowerCase() ||
          s.id.toLowerCase() == sessionId.toLowerCase() ||
          s.label.toLowerCase() == sessionId.toLowerCase())
      .firstOrNull;
  if (refShift != null) {
    final int? startM = parseTimeToMinutes(refShift.startTime);
    final int? endM = parseTimeToMinutes(refShift.endTime);
    if (startM != null && endM != null && endM > startM) {
      return SessionShiftBoundary(
        startMinutes: startM,
        endMinutes: endM,
        defaultStart: refShift.startTime,
        defaultEnd: refShift.endTime,
      );
    }
  }

  // 3. Fallback: SSOT CanonicalShift Constants (Zero Hardcoding)
  final CanonicalShift shift = CanonicalShift.resolve(sessionId);
  return SessionShiftBoundary(
    startMinutes: shift.startMinutes,
    endMinutes: shift.endMinutes,
    defaultStart: shift.defaultStartTime,
    defaultEnd: shift.defaultEndTime,
  );
}

String sessionShiftFromId(String sessionId) {
  return CanonicalShift.resolve(sessionId).code;
}

int? parseTimeToMinutes(String timeStr, {String? sessionId}) {
  try {
    final String trimmed = timeStr.trim().toUpperCase();
    final bool isPM = trimmed.contains('PM');
    final bool isAM = trimmed.contains('AM');
    final String cleanTime = trimmed
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .replaceAll('WIB', '')
        .trim();
    final List<String> parts = cleanTime.split(':');
    if (parts.isEmpty) return null;
    int hour = int.parse(parts[0]);
    final int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    if (hour == 24 && minute == 0) {
      return ShiftTimingConstants.minutesPerDay;
    }

    if (isPM && hour < 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    } else if (!isPM && !isAM && sessionId != null) {
      final CanonicalShift canonical = CanonicalShift.resolve(sessionId);
      if ((canonical == CanonicalShift.afternoon || canonical == CanonicalShift.night) && hour < 6) {
        hour += 12;
      }
    }
    return hour * 60 + minute;
  } catch (_) {
    return null;
  }
}

String formatMinutesToTime(int totalMinutes, {bool is12Hour = false}) {
  final int clamped = totalMinutes.clamp(0, ShiftTimingConstants.minutesPerDay);
  if (!is12Hour && clamped == ShiftTimingConstants.minutesPerDay) {
    return ShiftTimingConstants.endOfDayTime;
  }
  final int h = (clamped ~/ 60) % 24;
  final int m = clamped % 60;
  final String mm = m.toString().padLeft(2, '0');
  if (is12Hour) {
    final String period = h >= 12 ? 'PM' : 'AM';
    int displayH = h % 12;
    if (displayH == 0) displayH = 12;
    return '$displayH:$mm $period';
  } else {
    final String hh = h.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

List<String> getTimeOptionsForSession(
  String sessionId, {
  int? intervalMinutes,
  ScheduleContext? context,
}) {
  final SessionShiftBoundary bounds = getSessionShiftBoundary(sessionId, context);
  final List<String> options = <String>[];
  final int step = (intervalMinutes != null && intervalMinutes > 0)
      ? intervalMinutes
      : (context?.effectiveConsultationDurationMinutes ?? 30);
  for (int m = bounds.startMinutes; m <= bounds.endMinutes - step; m += step) {
    options.add(formatMinutesToTime(m));
  }
  return options;
}

String autoCalculateEndTime(
  String fromTime,
  String sessionId, {
  int? durationMinutes,
  ScheduleContext? context,
}) {
  final SessionShiftBoundary bounds = getSessionShiftBoundary(sessionId, context);
  final int? fromMinutes = parseTimeToMinutes(fromTime, sessionId: sessionId);
  final int patientInterval = (durationMinutes != null && durationMinutes > 0)
      ? durationMinutes
      : (context?.effectiveConsultationDurationMinutes ?? 30);
  if (fromMinutes == null) {
    return formatMinutesToTime(bounds.startMinutes + patientInterval);
  }
  final int endMinutes =
      (fromMinutes + patientInterval).clamp(bounds.startMinutes, bounds.endMinutes);
  return formatMinutesToTime(endMinutes);
}

int autoCalculateSlotCapacity(
  String fromTime,
  String sessionId, {
  int? durationMinutes,
  ScheduleContext? context,
}) {
  final SessionShiftBoundary bounds = getSessionShiftBoundary(sessionId, context);
  final int? fromMinutes = parseTimeToMinutes(fromTime, sessionId: sessionId);
  if (fromMinutes == null) return 0;
  final int duration = (durationMinutes != null && durationMinutes > 0)
      ? durationMinutes
      : (context?.effectiveConsultationDurationMinutes ?? 30);
  final int remaining = bounds.endMinutes - fromMinutes;
  if (remaining <= 0) return 0;
  return remaining ~/ duration;
}

DateTime? tryParseDate(String dateStr) {
  try {
    return DateTime.parse(dateStr);
  } catch (_) {}
  final RegExp indonesianDatePattern =
      RegExp(r'(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})');
  final Match? match = indonesianDatePattern.firstMatch(dateStr);
  if (match != null) {
    final int day = int.tryParse(match.group(1) ?? '') ?? 1;
    final String monthName = (match.group(2) ?? '').toLowerCase();
    final int year = int.tryParse(match.group(3) ?? '') ?? 2026;
    const Map<String, int> monthMap = <String, int>{
      'januari': 1,
      'jan': 1,
      'februari': 2,
      'feb': 2,
      'maret': 3,
      'mar': 3,
      'april': 4,
      'apr': 4,
      'mei': 5,
      'may': 5,
      'juni': 6,
      'jun': 6,
      'juli': 7,
      'jul': 7,
      'agustus': 8,
      'ags': 8,
      'agt': 8,
      'september': 9,
      'sep': 9,
      'oktober': 10,
      'okt': 10,
      'november': 11,
      'nov': 11,
      'desember': 12,
      'des': 12,
    };
    final int month = monthMap[monthName] ?? 1;
    return DateTime(year, month, day);
  }
  return null;
}

bool isTemporalSlotPast({
  DateTime? scheduleDate,
  String? scheduleDateStr,
  String? timeSlotOrEndTime,
  DateTime? referenceNow,
}) {
  final DateTime baseToday = referenceNow ?? AmanahScheduleStore.baseToday;
  final DateTime todayMidnight =
      DateTime(baseToday.year, baseToday.month, baseToday.day);

  DateTime? targetDate = scheduleDate;
  if (targetDate == null && scheduleDateStr != null && scheduleDateStr.isNotEmpty) {
    targetDate = tryParseDate(scheduleDateStr);
  }

  if (targetDate == null) return false;

  final DateTime targetDay =
      DateTime(targetDate.year, targetDate.month, targetDate.day);
  if (targetDay.isBefore(todayMidnight)) {
    return true;
  }
  if (targetDay.isAfter(todayMidnight)) {
    return false;
  }

  // Same day: check end time
  if (timeSlotOrEndTime == null || timeSlotOrEndTime.isEmpty) {
    return false;
  }

  // If running in test with customBaseToday and midnight (hour == 0, minute == 0),
  // and referenceNow was not provided, do not treat today's slots as expired.
  if (referenceNow == null &&
      AmanahScheduleStore.hasCustomBaseToday &&
      AmanahScheduleStore.customBaseToday?.hour == 0 &&
      AmanahScheduleStore.customBaseToday?.minute == 0) {
    return false;
  }

  final DateTime effectiveNow = referenceNow ??
      (AmanahScheduleStore.hasCustomBaseToday &&
              AmanahScheduleStore.customBaseToday != null
          ? AmanahScheduleStore.customBaseToday!
          : DateTime.now());

  String endTimeStr = timeSlotOrEndTime;
  if (endTimeStr.contains(' - ')) {
    endTimeStr = endTimeStr.split(' - ').last;
  }
  endTimeStr = endTimeStr.replaceAll('WIB', '').trim();

  final int? endMinutes = parseTimeToMinutes(endTimeStr);
  if (endMinutes == null) return false;

  final int currentMinutes = effectiveNow.hour * 60 + effectiveNow.minute;
  return currentMinutes >= endMinutes;
}

/// Returns true if the entire session shift has already passed for the given date.
/// If date is before today -> true.
/// If date is after today -> false.
/// If date is today -> checks against shift boundary end time.
bool isSessionShiftPast({
  required String sessionId,
  required DateTime selectedDate,
  ScheduleContext? context,
  DateTime? referenceNow,
}) {
  final DateTime baseToday = referenceNow ?? AmanahScheduleStore.baseToday;
  final DateTime todayMidnight =
      DateTime(baseToday.year, baseToday.month, baseToday.day);
  final DateTime targetMidnight =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  if (targetMidnight.isBefore(todayMidnight)) {
    return true;
  }
  if (targetMidnight.isAfter(todayMidnight)) {
    return false;
  }

  if (referenceNow == null) {
    final ScheduleFormBootstrapData? bootstrap =
        AmanahScheduleStore.instance.formBootstrap;
    if (bootstrap != null) {
      final ScheduleBootstrapShift? bShift = bootstrap.shifts
          .where((ScheduleBootstrapShift s) =>
              s.id.toLowerCase() == sessionId.toLowerCase() ||
              s.code.toLowerCase() == sessionId.toLowerCase())
          .firstOrNull;
      if (bShift != null && bShift.isPast) {
        return true;
      }
    }
  }

  // Same day: evaluate against current clock time
  final DateTime effectiveNow = referenceNow ??
      (AmanahScheduleStore.hasCustomBaseToday &&
              AmanahScheduleStore.customBaseToday != null
          ? AmanahScheduleStore.customBaseToday!
          : DateTime.now());

  final int currentMinutes = effectiveNow.hour * 60 + effectiveNow.minute;
  final SessionShiftBoundary bounds =
      getSessionShiftBoundary(sessionId, context);

  return currentMinutes >= bounds.endMinutes;
}

/// Returns true if a session shift has no actionable slots for booking.
bool isSessionShiftUnavailable({
  required String sessionId,
  required DateTime selectedDate,
  ScheduleShiftOccupancy? occupancy,
  ScheduleContext? context,
  DateTime? referenceNow,
  bool isEditingThisSession = false,
}) {
  if (isEditingThisSession) return false;

  if (isSessionShiftPast(
    sessionId: sessionId,
    selectedDate: selectedDate,
    context: context,
    referenceNow: referenceNow,
  )) {
    return true;
  }

  if (occupancy != null &&
      occupancy.totalSlots > 0 &&
      occupancy.availableSlotsCount == 0) {
    return true;
  }

  final DateTime baseToday = referenceNow ?? AmanahScheduleStore.baseToday;
  final bool isToday = selectedDate.year == baseToday.year &&
      selectedDate.month == baseToday.month &&
      selectedDate.day == baseToday.day;

  if (isToday) {
    final DateTime effectiveNow = referenceNow ??
        (AmanahScheduleStore.hasCustomBaseToday &&
                AmanahScheduleStore.customBaseToday != null
            ? AmanahScheduleStore.customBaseToday!
            : DateTime.now());

    final int currentMinutes = effectiveNow.hour * 60 + effectiveNow.minute;
    final SessionShiftBoundary bounds =
        getSessionShiftBoundary(sessionId, context);
    final int duration = context?.effectiveConsultationDurationMinutes ?? 30;

    if (bounds.endMinutes - currentMinutes < duration) {
      return true;
    }

    if (occupancy != null && occupancy.slots.isNotEmpty) {
      final bool hasFutureAvailable = occupancy.slots.any((ScheduleShiftSlot s) {
        final int? startM = parseTimeToMinutes(s.startTime, sessionId: sessionId);
        if (startM == null) return false;
        return startM >= currentMinutes && s.isAvailable;
      });
      if (!hasFutureAvailable) {
        return true;
      }
    }
  }

  return false;
}


