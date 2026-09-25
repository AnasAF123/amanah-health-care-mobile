import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

String sessionIdFromType(String sessionType) {
  if (sessionType == 'Dini Hari') {
    return 'dini_hari';
  }
  if (sessionType == 'Siang') {
    return 'siang';
  }
  if (sessionType == 'Malam') {
    return 'malam';
  }
  return 'pagi';
}

String getIndonesianMonthName(int month) {
  const List<String> months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String getIndonesianDayName(int weekday) {
  const List<String> days = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  return days[(weekday - 1).clamp(0, 6)];
}

String formatIndonesianDate(DateTime date) {
  return '${getIndonesianDayName(date.weekday)}, ${date.day} ${getIndonesianMonthName(date.month)} ${date.year}';
}

ScheduleFormSlot defaultSlotForSession(
  String sessionId, {
  String? id,
  String? defaultRoom,
  String? defaultPoli,
}) {
  return ScheduleFormSlot(
    id: id ?? '$sessionId-${DateTime.now().microsecondsSinceEpoch}',
    from: ScheduleFormConstants.selectTime,
    to: ScheduleFormConstants.emptyTime,
    room: (defaultRoom != null && defaultRoom.isNotEmpty)
        ? defaultRoom
        : ScheduleFormConstants.selectRoom,
    poli: (defaultPoli != null && defaultPoli.isNotEmpty)
        ? defaultPoli
        : ScheduleFormConstants.selectPoli,
  );
}

List<ScheduleFormSession> buildInitialScheduleSessions({
  DoctorSchedule? editingSchedule,
  ScheduleFormBootstrapData? bootstrap,
}) {
  final String? matchedId = editingSchedule == null
      ? null
      : sessionIdFromType(editingSchedule.sessionType);

  final List<({String id, String name, String sessionType})> defs =
      const <({String id, String name, String sessionType})>[
    (id: 'dini_hari', name: 'Sesi Dini Hari', sessionType: 'Dini Hari'),
    (id: 'pagi', name: 'Sesi Pagi', sessionType: 'Pagi'),
    (id: 'siang', name: 'Sesi Siang', sessionType: 'Siang'),
    (id: 'malam', name: 'Sesi Malam', sessionType: 'Malam'),
  ];

  final String? docDefaultRoom = bootstrap?.doctor.defaultRoomName;
  final String? docDefaultPoli = bootstrap?.doctor.defaultPoliklinikName;

  return defs.map((def) {
    final ScheduleBootstrapShift? bShift = bootstrap?.shifts
        .where((ScheduleBootstrapShift s) => s.id == def.id || s.code == def.id)
        .firstOrNull;

    final bool isMatchedEditing = matchedId != null && matchedId == def.id;
    final bool hasExisting = bShift?.existingSchedule != null;
    final bool isActive = isMatchedEditing || (editingSchedule == null && hasExisting);

    final List<ScheduleFormSlot> slots;
    if (isMatchedEditing && editingSchedule != null) {
      final SessionShiftBoundary bounds = getSessionShiftBoundary(def.id);
      slots = <ScheduleFormSlot>[
        ScheduleFormSlot(
          id: editingSchedule.id,
          from: editingSchedule.startTime ?? bounds.defaultStart,
          to: editingSchedule.endTime ?? bounds.defaultEnd,
          room: editingSchedule.room,
          poli: editingSchedule.poli,
        ),
      ];
    } else if (hasExisting && bShift != null) {
      final ScheduleBootstrapExistingSchedule ex = bShift.existingSchedule!;
      slots = <ScheduleFormSlot>[
        ScheduleFormSlot(
          id: ex.id,
          from: ex.startTime,
          to: ex.endTime,
          room: ex.roomName ?? docDefaultRoom ?? ScheduleFormConstants.selectRoom,
          poli: docDefaultPoli ?? ScheduleFormConstants.selectPoli,
        ),
      ];
    } else {
      slots = const <ScheduleFormSlot>[];
    }

    return ScheduleFormSession(
      id: def.id,
      name: def.name,
      sessionType: def.sessionType,
      active: isActive,
      slots: slots,
    );
  }).toList();
}

({String title, String message})? checkCanAddSlotError({
  required ScheduleFormSession session,
  required int duration,
  required SessionShiftBoundary bounds,
}) {
  if (session.slots.isEmpty) return null;
  final ScheduleFormSlot lastSlot = session.slots.last;
  if (lastSlot.from.isEmpty ||
      lastSlot.from == ScheduleFormConstants.selectTime ||
      lastSlot.to == ScheduleFormConstants.emptyTime) {
    return (
      title: 'Tentukan Jam Praktik',
      message: 'Silakan tentukan jam mulai pada antrean sebelumnya terlebih dahulu.',
    );
  }

  final int? lastEndMinutes =
      parseTimeToMinutes(lastSlot.to, sessionId: session.id);
  final int effectiveLastEnd = lastEndMinutes ?? bounds.endMinutes;
  final int remainingMinutes = bounds.endMinutes - effectiveLastEnd;

  if (remainingMinutes < duration) {
    return (
      title: 'Batas Shift Tercapai',
      message:
          'Sesi ${session.name} sudah terisi hingga batas shift (${bounds.defaultEnd} WIB). Setiap antrean membutuhkan minimal $duration menit.',
    );
  }
  return null;
}

List<ScheduleFormSession> updateSessionSlot({
  required List<ScheduleFormSession> sessions,
  required String sessionId,
  required int slotIndex,
  String? from,
  String? to,
  String? room,
  String? poli,
  int? durationMinutes,
  ScheduleContext? context,
}) {
  return sessions.map((ScheduleFormSession session) {
    if (session.id != sessionId) return session;
    final List<ScheduleFormSlot> slots = <ScheduleFormSlot>[
      for (int i = 0; i < session.slots.length; i++)
        if (i == slotIndex) ...[
          () {
            final ScheduleFormSlot currentSlot = session.slots[i];
            final String effectiveFrom = from ?? currentSlot.from;
            final String effectiveTo = from != null
                ? (effectiveFrom != ScheduleFormConstants.selectTime
                    ? autoCalculateEndTime(
                        effectiveFrom,
                        sessionId,
                        durationMinutes: durationMinutes,
                        context: context,
                      )
                    : ScheduleFormConstants.emptyTime)
                : (to ?? currentSlot.to);
            return currentSlot.copyWith(
              from: effectiveFrom,
              to: effectiveTo,
              room: room,
              poli: poli,
            );
          }()
        ] else
          session.slots[i],
    ];
    return session.copyWith(slots: slots);
  }).toList();
}

List<ScheduleFormSession> removeSessionSlot(
  List<ScheduleFormSession> sessions,
  String sessionId,
  int slotIndex,
) {
  return sessions.map((ScheduleFormSession session) {
    if (session.id != sessionId) return session;
    final List<ScheduleFormSlot> slots = <ScheduleFormSlot>[
      for (int i = 0; i < session.slots.length; i++)
        if (i != slotIndex) session.slots[i],
    ];
    return session.copyWith(slots: slots);
  }).toList();
}
