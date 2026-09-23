import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_notice_banner.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_duration_info_drawer.dart';

const List<String> kTimeOptions = <String>[];
const List<String> kRoomOptions = <String>[];
const List<String> kPoliOptions = <String>[];

class _SessionShiftBoundary {
  const _SessionShiftBoundary({
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

_SessionShiftBoundary _getSessionShiftBoundary(
  String sessionId, [
  ScheduleContext? context,
]) {
  if (context != null) {
    final int? startM = _parseTimeToMinutes(context.boundaryStartTime);
    final int? endM = _parseTimeToMinutes(context.boundaryEndTime);
    if (startM != null && endM != null && endM > startM) {
      return _SessionShiftBoundary(
        startMinutes: startM,
        endMinutes: endM,
        defaultStart: context.boundaryStartTime,
        defaultEnd: context.boundaryEndTime,
      );
    }
  }

  switch (sessionId) {
    case 'dini_hari':
    case 'early_morning':
      return const _SessionShiftBoundary(
        startMinutes: 0, // 00:00 WIB
        endMinutes: 6 * 60, // 06:00 WIB
        defaultStart: '00:00',
        defaultEnd: '06:00',
      );
    case 'pagi':
    case 'morning':
      return const _SessionShiftBoundary(
        startMinutes: 6 * 60, // 06:00 WIB
        endMinutes: 12 * 60, // 12:00 WIB
        defaultStart: '08:00',
        defaultEnd: '12:00',
      );
    case 'siang':
    case 'afternoon':
      return const _SessionShiftBoundary(
        startMinutes: 12 * 60, // 12:00 WIB
        endMinutes: 17 * 60, // 17:00 WIB
        defaultStart: '13:00',
        defaultEnd: '17:00',
      );
    case 'malam':
    case 'night':
      return const _SessionShiftBoundary(
        startMinutes: 17 * 60, // 17:00 WIB
        endMinutes: 21 * 60, // 21:00 WIB
        defaultStart: '19:00',
        defaultEnd: '21:00',
      );
    default:
      return const _SessionShiftBoundary(
        startMinutes: 8 * 60,
        endMinutes: 12 * 60,
        defaultStart: '08:00',
        defaultEnd: '12:00',
      );
  }
}

String _sessionShiftFromId(String sessionId) {
  switch (sessionId) {
    case 'dini_hari':
    case 'early_morning':
      return 'early_morning';
    case 'pagi':
    case 'morning':
      return 'morning';
    case 'siang':
    case 'afternoon':
      return 'afternoon';
    case 'malam':
    case 'night':
      return 'night';
    default:
      return 'morning';
  }
}

int? _parseTimeToMinutes(String timeStr, {String? sessionId}) {
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

    if (isPM && hour < 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    } else if (!isPM && !isAM && sessionId != null) {
      if ((sessionId == 'siang' || sessionId == 'malam') && hour < 6) {
        hour += 12;
      }
    }
    return hour * 60 + minute;
  } catch (_) {
    return null;
  }
}

String _formatMinutesToTime(int totalMinutes, {bool is12Hour = false}) {
  final int clamped = totalMinutes.clamp(0, 24 * 60);
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

List<String> _getTimeOptionsForSession(
  String sessionId, {
  int? intervalMinutes,
  ScheduleContext? context,
}) {
  final _SessionShiftBoundary bounds = _getSessionShiftBoundary(sessionId, context);
  final List<String> options = <String>[];
  final int step = (intervalMinutes != null && intervalMinutes > 0)
      ? intervalMinutes
      : (context?.effectiveConsultationDurationMinutes ?? 30);
  for (int m = bounds.startMinutes; m <= bounds.endMinutes - step; m += step) {
    options.add(_formatMinutesToTime(m));
  }
  return options;
}

String _autoCalculateEndTime(
  String fromTime,
  String sessionId, {
  int? durationMinutes,
  ScheduleContext? context,
}) {
  final _SessionShiftBoundary bounds = _getSessionShiftBoundary(sessionId, context);
  final int? fromMinutes = _parseTimeToMinutes(fromTime, sessionId: sessionId);

  // Authoritative duration policy from database: practitioners.consultation_duration_minutes
  final int patientInterval = (durationMinutes != null && durationMinutes > 0)
      ? durationMinutes
      : (context?.effectiveConsultationDurationMinutes ?? 30);

  if (fromMinutes == null) {
    return _formatMinutesToTime(
      (bounds.startMinutes + patientInterval).clamp(bounds.startMinutes, bounds.endMinutes),
    );
  }

  final int shiftBoundaryEnd = bounds.endMinutes;
  final int effectiveStart =
      fromMinutes.clamp(bounds.startMinutes, bounds.endMinutes);

  // Setiap antrean/slot berdurasi persis sesuai kebijakan durasi dokter (default 30 menit)
  final int endMinutes =
      (effectiveStart + patientInterval).clamp(bounds.startMinutes, shiftBoundaryEnd);

  return _formatMinutesToTime(endMinutes);
}


/// 7. Monthly Doctor Schedule Big Calendar Drawer Modal ("Lihat Schedule")
class AmanahDocScheduleCalendarDrawer extends StatefulWidget {
  const AmanahDocScheduleCalendarDrawer({
    required this.selectedDate,
    required this.baseToday,
    required this.onSelectDate,
    super.key,
  });

  final DateTime selectedDate;
  final DateTime baseToday;
  final ValueChanged<DateTime> onSelectDate;

  static void show(
    BuildContext context, {
    required DateTime selectedDate,
    required DateTime baseToday,
    required ValueChanged<DateTime> onSelectDate,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahDocScheduleCalendarDrawer(
        selectedDate: selectedDate,
        baseToday: baseToday,
        onSelectDate: onSelectDate,
      ),
    );
  }

  @override
  State<AmanahDocScheduleCalendarDrawer> createState() =>
      _AmanahDocScheduleCalendarDrawerState();
}

class _AmanahDocScheduleCalendarDrawerState
    extends State<AmanahDocScheduleCalendarDrawer> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    _loadCalendarSummary();
  }

  void _loadCalendarSummary() {
    final String monthStr =
        '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    AmanahScheduleStore.instance.loadCalendarSummary(monthStr);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final AmanahScheduleStore store = AmanahScheduleStore.instance;

    final DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
    );
    final DateTime lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final DateTime gridStart = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final DateTime gridEnd = lastDayOfMonth.add(
      Duration(days: 6 - (lastDayOfMonth.weekday % 7)),
    );
    final int gridDayCount = gridEnd.difference(gridStart).inDays + 1;

    return AmanahBottomSheetScaffold(
      title: 'Kalender Jadwal Praktik',
      maxHeightFactor: 0.76,
      minHeight: 430,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Month Switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                  _loadCalendarSummary();
                },
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                  _loadCalendarSummary();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _DayHeader('Min'),
              _DayHeader('Sen'),
              _DayHeader('Sel'),
              _DayHeader('Rab'),
              _DayHeader('Kam'),
              _DayHeader('Jum'),
              _DayHeader('Sab'),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDayCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = gridStart.add(Duration(days: index));
              final bool inCurrentMonth = date.month == _currentMonth.month;
              if (!inCurrentMonth) {
                return const SizedBox.shrink();
              }
              final bool isSelected = _isSameDay(date, widget.selectedDate);
              final bool isToday = _isSameDay(date, widget.baseToday);
              final bool isPast = date.isBefore(
                DateTime(
                  widget.baseToday.year,
                  widget.baseToday.month,
                  widget.baseToday.day,
                ),
              );
              final DayScheduleSetting setting = store.getDaySettingForDate(
                date,
              );
              final bool isCuti = setting.isCuti;
              final List<DoctorSchedule> schedules = store.getSchedulesForDate(
                date,
              );
              final bool hasSchedules = schedules.isNotEmpty;

              Color bgColor = Colors.transparent;
              Color textColor = dark
                  ? AmanahColorTokens.pureWhite
                  : AmanahColorTokens.neutral900;
              Color? dotColor;

              if (isSelected) {
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : (isCuti
                          ? AmanahColorTokens.warning
                          : AmanahColorTokens.brand);
                textColor = dark
                    ? AmanahColorTokens.canvasDark
                    : AmanahColorTokens.surfaceLight;
              } else if (isToday) {
                bgColor =
                    (dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand)
                        .withValues(alpha: 0.15);
                textColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand;
                dotColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand;
              } else if (isPast) {
                textColor = dark
                    ? AmanahColorTokens.neutral500
                    : AmanahColorTokens.neutral300;
              } else if (isCuti) {
                dotColor = AmanahColorTokens.warning;
              } else if (hasSchedules) {
                dotColor = AmanahColorTokens.success;
              } else {
                dotColor = dark
                    ? AmanahColorTokens.neutral500
                    : AmanahColorTokens.neutral300;
              }

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isPast
                    ? null
                    : () {
                        widget.onSelectDate(date);
                        Navigator.of(context).pop();
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: (isSelected || isToday)
                              ? FontWeight.w900
                              : FontWeight.w600,
                        ),
                      ),
                      if (dotColor != null && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              _CalendarLegendDot(
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
                label: 'Hari ini',
              ),
              const _CalendarLegendDot(
                color: AmanahColorTokens.success,
                label: 'Ada sesi',
              ),
              const _CalendarLegendDot(
                color: AmanahColorTokens.warning,
                label: 'Cuti',
              ),
              const _CalendarLegendDot(
                color: AmanahColorTokens.neutral400,
                label: 'Tutup',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
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
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox(width: 7, height: 7),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral400
                : AmanahColorTokens.neutral500,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AmanahColorTokens.neutral400,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScheduleFormSlot {
  const _ScheduleFormSlot({
    required this.id,
    required this.from,
    required this.to,
    required this.room,
    required this.poli,
  });

  final String id;
  final String from;
  final String to;
  final String room;
  final String poli;

  _ScheduleFormSlot copyWith({
    String? from,
    String? to,
    String? room,
    String? poli,
  }) {
    return _ScheduleFormSlot(
      id: id,
      from: from ?? this.from,
      to: to ?? this.to,
      room: room ?? this.room,
      poli: poli ?? this.poli,
    );
  }
}

class _ScheduleFormSession {
  const _ScheduleFormSession({
    required this.id,
    required this.name,
    required this.sessionType,
    required this.active,
    required this.slots,
  });

  final String id;
  final String name;
  final String sessionType;
  final bool active;
  final List<_ScheduleFormSlot> slots;

  _ScheduleFormSession copyWith({
    bool? active,
    List<_ScheduleFormSlot>? slots,
  }) {
    return _ScheduleFormSession(
      id: id,
      name: name,
      sessionType: sessionType,
      active: active ?? this.active,
      slots: slots ?? this.slots,
    );
  }
}

/// 8. Master Add & Edit Schedule Form Drawer (Doctor POV)
class AmanahAddEditScheduleDrawer extends StatefulWidget {
  const AmanahAddEditScheduleDrawer({
    required this.initialDate,
    this.scheduleToEdit,
    this.onSavedDate,
    super.key,
  });

  final DateTime initialDate;
  final DoctorSchedule? scheduleToEdit;
  final ValueChanged<DateTime>? onSavedDate;

  static void show(
    BuildContext context, {
    required DateTime initialDate,
    DoctorSchedule? scheduleToEdit,
    ValueChanged<DateTime>? onSavedDate,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahAddEditScheduleDrawer(
        initialDate: initialDate,
        scheduleToEdit: scheduleToEdit,
        onSavedDate: onSavedDate,
      ),
    );
  }

  @override
  State<AmanahAddEditScheduleDrawer> createState() =>
      _AmanahAddEditScheduleDrawerState();
}

class _AmanahAddEditScheduleDrawerState
    extends State<AmanahAddEditScheduleDrawer> {
  late DateTime _selectedDate;
  late DateTime _calendarMonth;
  bool _isCalendarOpen = false;
  String _status = 'Buka'; // 'Buka', 'Terisi', 'Tutup'
  List<_ScheduleFormSession> _sessions = const <_ScheduleFormSession>[];
  List<ClinicPoliklinikReference> _polis = const <ClinicPoliklinikReference>[];
  List<ClinicRoomReference> _rooms = const <ClinicRoomReference>[];
  List<String> _dynamicPoliOptions = kPoliOptions;
  List<String> _dynamicRoomOptions = kRoomOptions;
  List<String> _occupiedRoomOptions = const <String>[];
  final List<String> _dynamicStatusOptions = const <String>['Buka', 'Terisi', 'Tutup'];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _calendarMonth = DateTime(_selectedDate.year, _selectedDate.month);
    final DoctorSchedule? sch = widget.scheduleToEdit;
    if (sch != null) {
      _status = sch.badge;
      _sessions = _buildInitialSessions(editingSchedule: sch);
    } else {
      _status = 'Buka';
      _sessions = _buildInitialSessions();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadReferenceData();
      }
    });
  }

  ScheduleContext? _getContextForSession(String sessionId) {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String targetShift = _sessionShiftFromId(sessionId);
    return store.scheduleContexts
        .where((ScheduleContext c) =>
            c.sessionShift == targetShift ||
            c.contextId == sessionId ||
            c.contextId == targetShift)
        .firstOrNull;
  }

  int _getEffectiveDurationForSession(String sessionId) {
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    if (ctx != null && ctx.effectiveConsultationDurationMinutes > 0) {
      return ctx.effectiveConsultationDurationMinutes;
    }
    return 30; // Database default: practitioners.consultation_duration_minutes
  }

  Future<void> _loadOccupancyData([String? preferredRoomName]) async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    String? roomId;
    if (preferredRoomName != null && preferredRoomName != 'Pilih Ruang Praktik') {
      roomId = _rooms
          .where((ClinicRoomReference r) => r.name == preferredRoomName)
          .firstOrNull
          ?.id;
    } else {
      for (final _ScheduleFormSession s in _sessions) {
        for (final _ScheduleFormSlot sl in s.slots) {
          if (sl.room.isNotEmpty && sl.room != 'Pilih Ruang Praktik') {
            roomId = _rooms
                .where((ClinicRoomReference r) => r.name == sl.room)
                .firstOrNull
                ?.id;
            if (roomId != null) break;
          }
        }
        if (roomId != null) break;
      }
    }

    await store.loadOccupancyOverview(date: _selectedDate, roomId: roomId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadReferenceData() async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final List<ClinicPoliklinikReference> polis =
        await store.loadPolikliniks();
    final List<ClinicRoomReference> rooms =
        await store.loadRooms(date: _selectedDate);
    await store.loadScheduleContexts(_selectedDate);

    if (!mounted) return;
    setState(() {
      if (polis.isNotEmpty) {
        _polis = polis;
        _dynamicPoliOptions =
            polis.map((ClinicPoliklinikReference p) => p.name).toList();
      }
      if (rooms.isNotEmpty) {
        _rooms = rooms;
        _dynamicRoomOptions =
            rooms.map((ClinicRoomReference r) => r.name).toList();
        _occupiedRoomOptions = rooms
            .where((ClinicRoomReference r) => r.isOccupied)
            .map((ClinicRoomReference r) => r.name)
            .toList();
      }
    });

    await _loadOccupancyData();
  }

  List<_ScheduleFormSession> _buildInitialSessions({
    DoctorSchedule? editingSchedule,
  }) {
    final String? matchedId = editingSchedule == null
        ? null
        : _sessionIdFromType(editingSchedule.sessionType);

    final List<({String id, String name, String sessionType})> defs =
        const <({String id, String name, String sessionType})>[
      (id: 'dini_hari', name: 'Sesi Dini Hari', sessionType: 'Dini Hari'),
      (id: 'pagi', name: 'Sesi Pagi', sessionType: 'Pagi'),
      (id: 'siang', name: 'Sesi Siang', sessionType: 'Siang'),
      (id: 'malam', name: 'Sesi Malam', sessionType: 'Malam'),
    ];

    return defs.map((def) {
      final bool isActive = matchedId != null && matchedId == def.id;
      final List<_ScheduleFormSlot> slots;
      if (isActive && editingSchedule != null) {
        final _SessionShiftBoundary bounds = _getSessionShiftBoundary(def.id);
        slots = <_ScheduleFormSlot>[
          _ScheduleFormSlot(
            id: editingSchedule.id,
            from: editingSchedule.startTime ?? bounds.defaultStart,
            to: editingSchedule.endTime ?? bounds.defaultEnd,
            room: editingSchedule.room,
            poli: editingSchedule.poli,
          ),
        ];
      } else {
        slots = const <_ScheduleFormSlot>[];
      }
      return _ScheduleFormSession(
        id: def.id,
        name: def.name,
        sessionType: def.sessionType,
        active: isActive,
        slots: slots,
      );
    }).toList();
  }

  void _showConflictDialog(
    BuildContext context,
    String message, {
    String title = 'Validasi Jadwal Praktik',
    String subtitle = 'Validasi Sistem Praktik Dokter',
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        final bool dark = Theme.of(ctx).brightness == Brightness.dark;
        return AmanahBottomSheetScaffold(
          title: title,
          subtitle: subtitle,
          maxHeightFactor: 0.45,
          footer: AmanahButton.primary(
            text: 'Mengerti',
            isFullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AmanahColorTokens.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AmanahColorTokens.warning.withValues(alpha: 0.40),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AmanahColorTokens.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveSchedule() async {
    setState(() => _isSubmitting = true);
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String dateStr =
        '${_getDayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    final List<_ScheduleFormSession> activeSessions = _sessions
        .where((_ScheduleFormSession session) =>
            session.active && session.slots.isNotEmpty)
        .toList();
    if (activeSessions.isEmpty) {
      setState(() => _isSubmitting = false);
      _showConflictDialog(
        context,
        'Aktifkan minimal satu sesi praktik untuk menyimpan jadwal.',
        title: 'Validasi Jadwal Praktik',
      );
      return;
    }

    for (final _ScheduleFormSession s in activeSessions) {
      for (final _ScheduleFormSlot slot in s.slots) {
        if (slot.room.isEmpty || slot.room == 'Pilih Ruang Praktik') {
          setState(() => _isSubmitting = false);
          _showConflictDialog(
            context,
            'Silakan pilih Ruang Praktik untuk ${s.name}.',
            title: 'Validasi Jadwal Praktik',
          );
          return;
        }
        if (slot.poli.isEmpty || slot.poli == 'Pilih Poliklinik') {
          setState(() => _isSubmitting = false);
          _showConflictDialog(
            context,
            'Silakan pilih Poli / Spesialisasi untuk ${s.name}.',
            title: 'Validasi Jadwal Praktik',
          );
          return;
        }
      }
    }

    final List<_ScheduleFormSession> targetSessions = activeSessions;
    final _ScheduleFormSession firstActive = targetSessions.first;
    final _ScheduleFormSlot firstSlot = firstActive.slots.first;
    final String timeStr = '${firstSlot.from} - ${firstSlot.to} WIB';

    try {
      final String? roomId = _rooms
              .where((ClinicRoomReference r) => r.name == firstSlot.room)
              .firstOrNull
              ?.id ??
          (_rooms.isNotEmpty ? _rooms.first.id : null);
      final String? poliId = _polis
              .where((ClinicPoliklinikReference p) => p.name == firstSlot.poli)
              .firstOrNull
              ?.id ??
          (_polis.isNotEmpty ? _polis.first.id : null);

      if (widget.scheduleToEdit != null) {
        final DoctorSchedule updated = widget.scheduleToEdit!.copyWith(
          title: firstActive.name,
          date: dateStr,
          time: timeStr,
          startTime: firstSlot.from,
          endTime: firstSlot.to,
          sessionType: firstActive.sessionType,
          poli: firstSlot.poli,
          room: firstSlot.room,
          roomId: roomId ?? widget.scheduleToEdit!.roomId,
          poliklinikId: poliId ?? widget.scheduleToEdit!.poliklinikId,
          badge: _status,
          badgeVariant: _status == 'Tutup' || _status == 'Cuti'
              ? AmanahBadgeVariant.warning
              : (_status == 'Terisi'
                    ? AmanahBadgeVariant.primary
                    : AmanahBadgeVariant.success),
        );
        await store.saveSchedule(_selectedDate, updated);
      } else {
        for (int index = 0; index < targetSessions.length; index++) {
          final _ScheduleFormSession session = targetSessions[index];
          for (final _ScheduleFormSlot slot in session.slots) {
            final String? slotRoomId = _rooms
                    .where((ClinicRoomReference r) => r.name == slot.room)
                    .firstOrNull
                    ?.id ??
                (_rooms.isNotEmpty ? _rooms.first.id : null);
            final String? slotPoliId = _polis
                    .where((ClinicPoliklinikReference p) => p.name == slot.poli)
                    .firstOrNull
                    ?.id ??
                (_polis.isNotEmpty ? _polis.first.id : null);

            final DoctorSchedule newSch = DoctorSchedule(
              id: 'ses-${DateTime.now().millisecondsSinceEpoch}-${session.id}-$index',
              title: session.name,
              date: dateStr,
              time: '${slot.from} - ${slot.to} WIB',
              startTime: slot.from,
              endTime: slot.to,
              sessionType: session.sessionType,
              sessionShift: _sessionIdFromType(session.sessionType),
              poli: slot.poli,
              room: slot.room,
              roomId: slotRoomId,
              poliklinikId: slotPoliId,
              slotCount: '0',
              slotText: '0 Pasien Booking',
              badge: _status,
              badgeVariant: _status == 'Tutup' || _status == 'Cuti'
                  ? AmanahBadgeVariant.warning
                  : (_status == 'Terisi'
                        ? AmanahBadgeVariant.primary
                        : AmanahBadgeVariant.success),
              bookedPatients: const <BookedPatient>[],
            );

            // Forward to authoritative Schedule V2 backend availability endpoint
            try {
              final ScheduleContext? ctx = _getContextForSession(session.id);
              final String contextId = ctx?.contextId ?? _sessionShiftFromId(session.id);
              await store.createAvailability(
                date: _selectedDate,
                scheduleContextId: contextId,
                startTime: slot.from,
                roomId: slotRoomId,
                poliklinikId: slotPoliId,
              );
            } on AmanahScheduleConflictException {
              rethrow;
            } catch (_) {
              // Backward-compatible fallback
              await store.saveSchedule(_selectedDate, newSch);
            }
          }
        }
      }
      widget.onSavedDate?.call(_selectedDate);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on AmanahScheduleConflictException catch (e) {
      if (mounted) {
        _showConflictDialog(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        _showConflictDialog(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteSchedule() async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    if (widget.scheduleToEdit != null) {
      try {
        await store.removeSchedule(
          _selectedDate,
          widget.scheduleToEdit!.id,
        );
        widget.onSavedDate?.call(_selectedDate);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } on AmanahScheduleConflictException catch (e) {
        if (mounted) {
          _showConflictDialog(context, e.message);
        }
      } catch (_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void _toggleSession(String sessionId, [bool? forcedState]) {
    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession session) {
        if (session.id != sessionId) {
          return session;
        }
        final bool nextActive = forcedState ?? !session.active;
        final List<_ScheduleFormSlot> slots =
            nextActive && session.slots.isEmpty
            ? <_ScheduleFormSlot>[_defaultSlotForSession(session.id)]
            : session.slots;
        return session.copyWith(active: nextActive, slots: slots);
      }).toList();
    });
  }

  void _addTimeSlot(String sessionId) {
    final _ScheduleFormSession session = _sessions.firstWhere(
      (_ScheduleFormSession s) => s.id == sessionId,
      orElse: () => _sessions.first,
    );

    final int duration = _getEffectiveDurationForSession(sessionId);
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    final _SessionShiftBoundary bounds = _getSessionShiftBoundary(sessionId, ctx);

    if (session.slots.isEmpty) {
      setState(() {
        _sessions = _sessions.map((_ScheduleFormSession s) {
          if (s.id == sessionId) {
            return s.copyWith(
              slots: <_ScheduleFormSlot>[_defaultSlotForSession(sessionId)],
            );
          }
          return s;
        }).toList();
      });
      return;
    }

    final _ScheduleFormSlot lastSlot = session.slots.last;
    final int? lastEndMinutes =
        _parseTimeToMinutes(lastSlot.to, sessionId: sessionId);
    final int effectiveLastEnd = lastEndMinutes ?? bounds.endMinutes;
    final int remainingMinutes = bounds.endMinutes - effectiveLastEnd;

    if (remainingMinutes < duration) {
      final String bannerText =
          'Sesi ${session.name} sudah terisi hingga batas shift (${bounds.defaultEnd} WIB). Setiap antrean membutuhkan minimal $duration menit.';
      _showConflictDialog(
        context,
        bannerText,
        title: 'Batas Shift Tercapai',
      );
      return;
    }

    final String nextFrom = lastSlot.to;
    final String nextTo = _autoCalculateEndTime(
      nextFrom,
      sessionId,
      durationMinutes: duration,
      context: ctx,
    );

    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession s) {
        if (s.id != sessionId) return s;
        return s.copyWith(
          slots: <_ScheduleFormSlot>[
            ...s.slots,
            _ScheduleFormSlot(
              id: '$sessionId-${DateTime.now().microsecondsSinceEpoch}',
              from: nextFrom,
              to: nextTo,
              room: 'Pilih Ruang Praktik',
              poli: 'Pilih Poliklinik',
            ),
          ],
        );
      }).toList();
    });
  }

  void _removeTimeSlot(String sessionId, int slotIndex) {
    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession session) {
        if (session.id != sessionId) {
          return session;
        }
        final List<_ScheduleFormSlot> slots = <_ScheduleFormSlot>[
          for (int i = 0; i < session.slots.length; i++)
            if (i != slotIndex) session.slots[i],
        ];
        return session.copyWith(slots: slots);
      }).toList();
    });
  }

  void _updateSlot(
    String sessionId,
    int slotIndex, {
    String? from,
    String? to,
    String? room,
    String? poli,
  }) {
    final int duration = _getEffectiveDurationForSession(sessionId);
    final ScheduleContext? ctx = _getContextForSession(sessionId);

    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession session) {
        if (session.id != sessionId) {
          return session;
        }
        final List<_ScheduleFormSlot> slots = <_ScheduleFormSlot>[
          for (int i = 0; i < session.slots.length; i++)
            if (i == slotIndex) ...[
              () {
                final _ScheduleFormSlot currentSlot = session.slots[i];
                final String effectiveFrom = from ?? currentSlot.from;
                final String effectiveTo = from != null
                    ? _autoCalculateEndTime(
                        effectiveFrom,
                        sessionId,
                        durationMinutes: duration,
                        context: ctx,
                      )
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
    });

    if (room != null && room != 'Pilih Ruang Praktik') {
      _loadOccupancyData(room);
    }
  }

  _ScheduleFormSlot _defaultSlotForSession(String sessionId, {String? id}) {
    final int duration = _getEffectiveDurationForSession(sessionId);
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    final _SessionShiftBoundary bounds = _getSessionShiftBoundary(sessionId, ctx);
    final String targetShift = _sessionShiftFromId(sessionId);
    final ScheduleShiftOccupancy? shiftOcc = AmanahScheduleStore
        .instance.occupancyOverview?.shifts
        .where((ScheduleShiftOccupancy s) => s.shift == targetShift)
        .firstOrNull;

    final String initialFrom = shiftOcc?.slots
            .where((ScheduleShiftSlot s) => s.isAvailable)
            .firstOrNull
            ?.startTime ??
        bounds.defaultStart;
    final String initialTo = _autoCalculateEndTime(
      initialFrom,
      sessionId,
      durationMinutes: duration,
      context: ctx,
    );
    const String initialRoom = 'Pilih Ruang Praktik';
    const String initialPoli = 'Pilih Poliklinik';

    return _ScheduleFormSlot(
      id: id ?? '$sessionId-${DateTime.now().microsecondsSinceEpoch}',
      from: initialFrom,
      to: initialTo,
      room: initialRoom,
      poli: initialPoli,
    );
  }

  Future<void> _openSelectionSheet({
    required String title,
    required String subtitle,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    List<String> disabledOptions = const <String>[],
    Map<String, String> optionSubtitles = const <String, String>{},
    String? sessionId,
    bool isTimePicker = false,
  }) async {
    List<String> effectiveOptions = options;
    List<String> effectiveDisabled = disabledOptions;

    if (!isTimePicker) {
      if (options == kRoomOptions) {
        if (_dynamicRoomOptions.isNotEmpty) {
          effectiveOptions = _dynamicRoomOptions;
        }
        effectiveDisabled = _occupiedRoomOptions;
      } else if (options == kPoliOptions) {
        if (_dynamicPoliOptions.isNotEmpty) {
          effectiveOptions = _dynamicPoliOptions;
        }
      }
    }

    final String? selected = await showAmanahBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => _AmanahScheduleSelectionSheet(
        title: title,
        subtitle: subtitle,
        currentValue: currentValue,
        options: effectiveOptions,
        disabledOptions: effectiveDisabled,
        optionSubtitles: optionSubtitles,
        sessionId: sessionId,
        isTimePicker: isTimePicker,
      ),
    );
    if (selected != null && mounted) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final bool isEditing = widget.scheduleToEdit != null;

    return AmanahBottomSheetScaffold(
      title: isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
      trailing: Tooltip(
        message: 'Informasi Ketentuan Praktik',
        triggerMode: TooltipTriggerMode.tap,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            final int duration = _getEffectiveDurationForSession(
              _sessions.where((_ScheduleFormSession s) => s.active).firstOrNull?.id ?? 'pagi',
            );
            AmanahScheduleDurationInfoDrawer.show(
              context,
              durationMinutes: duration,
            );
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AmanahColorTokens.brand.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: dark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brand,
            ),
          ),
        ),
      ),
      fixedHeightFactor: 0.90,
      minHeight: 520,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahActionRow(
        axis: isEditing
            ? AmanahActionRowAxis.vertical
            : AmanahActionRowAxis.horizontal,
        primary: AmanahButton.primary(
          text: isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          isLoading: _isSubmitting,
          onPressed: _saveSchedule,
        ),
        secondary: isEditing
            ? AmanahButton.ghost(
                text: 'Hapus',
                size: AmanahButtonSize.medium,
                isFullWidth: true,
                customForegroundColor: AmanahColorTokens.dangerDark,
                onPressed: _deleteSchedule,
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isEditing) ...<Widget>[
            Text(
              'Status Praktik',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral200
                    : AmanahColorTokens.neutral700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                    : AmanahColorTokens.surfaceSecondaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                      : AmanahColorTokens.neutral200,
                ),
              ),
              child: Row(
                children: _dynamicStatusOptions.map((String label) {
                  final bool active = _status == label;
                  Color activeBg = AmanahColorTokens.success;
                  Color dotColor = AmanahColorTokens.emeraldLight;
                  if (label == 'Terisi') {
                    activeBg = AmanahColorTokens.brand;
                    dotColor = AmanahColorTokens.brandLight;
                  } else if (label == 'Tutup' || label == 'Cuti') {
                    activeBg = AmanahColorTokens.danger;
                    dotColor = AmanahColorTokens.roseLight;
                  }
                  final Color selectedBg =
                      dark ? AmanahColorTokens.tabActiveDark : activeBg;
                  final Color selectedText = dark
                      ? AmanahColorTokens.canvasDark
                      : AmanahColorTokens.surfaceLight;

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _status = label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? selectedBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: active
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: selectedBg.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: active ? selectedText : dotColor,
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox(width: 6, height: 6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: active
                                    ? selectedText
                                    : (dark
                                        ? AmanahColorTokens.neutral400
                                        : AmanahColorTokens.neutral600),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'Tanggal Praktik',
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.neutral200
                  : AmanahColorTokens.neutral700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          _ScheduleSelectorButton(
            value:
                '${_getDayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
            icon: Icons.calendar_today_rounded,
            dark: dark,
            expanded: _isCalendarOpen,
            onTap: () => setState(() => _isCalendarOpen = !_isCalendarOpen),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _isCalendarOpen
                ? Padding(
                    key: const ValueKey<String>('inline-form-calendar'),
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildInlineCalendar(dark),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),
          Text(
            'Sesi Praktik & Jam',
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.neutral200
                  : AmanahColorTokens.neutral700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            children: <Widget>[
              for (final _ScheduleFormSession session in _sessions) ...<Widget>[
                () {
                  final String targetShift = _sessionShiftFromId(session.id);
                  final ScheduleShiftOccupancy? shiftOcc = AmanahScheduleStore
                      .instance.occupancyOverview?.shifts
                      .where((ScheduleShiftOccupancy s) => s.shift == targetShift)
                      .firstOrNull;

                  return _ScheduleSessionPanel(
                    session: session,
                    occupancy: shiftOcc,
                    dark: dark,
                    onToggle: (bool value) => _toggleSession(session.id, value),
                    onSlotChanged: ({
                      required int slotIndex,
                      String? from,
                      String? to,
                      String? room,
                      String? poli,
                    }) {
                      _updateSlot(
                        session.id,
                        slotIndex,
                        from: from,
                        to: to,
                        room: room,
                        poli: poli,
                      );
                    },
                    onAddSlot: () => _addTimeSlot(session.id),
                    onRemoveSlot: (int slotIndex) =>
                        _removeTimeSlot(session.id, slotIndex),
                    onOpenSelection: _openSelectionSheet,
                  );
                }(),
                const SizedBox(height: 10),
              ],
            ],
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
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

  String _sessionIdFromType(String sessionType) {
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

  String _getDayName(int weekday) {
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildInlineCalendar(bool dark) {
    final DateTime firstDayOfMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month,
    );
    final DateTime lastDayOfMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + 1,
      0,
    );
    final DateTime gridStart = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final DateTime gridEnd = lastDayOfMonth.add(
      Duration(days: 6 - (lastDayOfMonth.weekday % 7)),
    );
    final int gridDayCount = gridEnd.difference(gridStart).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: () => setState(() {
                  _calendarMonth = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month - 1,
                  );
                }),
              ),
              Expanded(
                child: Text(
                  '${_getMonthName(_calendarMonth.month)} ${_calendarMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral900,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () => setState(() {
                  _calendarMonth = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month + 1,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: <Widget>[
              Expanded(child: _DayHeader('Min')),
              Expanded(child: _DayHeader('Sen')),
              Expanded(child: _DayHeader('Sel')),
              Expanded(child: _DayHeader('Rab')),
              Expanded(child: _DayHeader('Kam')),
              Expanded(child: _DayHeader('Jum')),
              Expanded(child: _DayHeader('Sab')),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDayCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 34,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = gridStart.add(Duration(days: index));
              final bool inCurrentMonth = date.month == _calendarMonth.month;
              final bool isSelected = _isSameDay(date, _selectedDate);
              final bool isToday = _isSameDay(
                date,
                AmanahScheduleStore.baseToday,
              );
              Color bgColor = Colors.transparent;
              Color textColor = inCurrentMonth
                  ? (dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral900)
                  : (dark
                        ? AmanahColorTokens.neutral600
                        : AmanahColorTokens.neutral300);
              if (isSelected) {
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand;
                textColor = dark
                    ? AmanahColorTokens.canvasDark
                    : AmanahColorTokens.surfaceLight;
              } else if (isToday) {
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.15)
                    : AmanahColorTokens.brandLight;
                textColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand;
              }

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    _calendarMonth = DateTime(date.year, date.month);
                    _isCalendarOpen = false;
                  });
                  _loadReferenceData();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color:
                                  (dark
                                          ? AmanahColorTokens.tabActiveDark
                                          : AmanahColorTokens.brand)
                                      .withValues(alpha: 0.24),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: (isSelected || isToday)
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScheduleSelectorButton extends StatelessWidget {
  const _ScheduleSelectorButton({
    required this.value,
    required this.icon,
    required this.dark,
    required this.onTap,
    this.expanded = false,
  });

  final String value;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Color background = dark
        ? (expanded
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
              : AmanahColorTokens.pureWhite.withValues(alpha: 0.05))
        : (expanded
              ? AmanahColorTokens.neutral200
              : AmanahColorTokens.surfaceSecondaryLight);
    final Color iconBackground = dark
        ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.12)
        : AmanahColorTokens.brandLight;
    final Color accent = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.brand;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AmanahColorTokens.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSlotEntry extends StatelessWidget {
  const _AnimatedSlotEntry({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: Transform.scale(
              scale: 0.98 + (value * 0.02),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

typedef _OpenScheduleSelectionSheet =
    Future<void> Function({
      required String title,
      required String subtitle,
      required String currentValue,
      required List<String> options,
      required ValueChanged<String> onChanged,
      List<String> disabledOptions,
      Map<String, String> optionSubtitles,
      String? sessionId,
      bool isTimePicker,
    });

typedef _ScheduleSlotChanged =
    void Function({
      required int slotIndex,
      String? from,
      String? to,
      String? room,
      String? poli,
    });

class _ScheduleSessionPanel extends StatelessWidget {
  const _ScheduleSessionPanel({
    required this.session,
    this.occupancy,
    required this.dark,
    required this.onToggle,
    required this.onSlotChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onOpenSelection,
  });

  final _ScheduleFormSession session;
  final ScheduleShiftOccupancy? occupancy;
  final bool dark;
  final ValueChanged<bool> onToggle;
  final _ScheduleSlotChanged onSlotChanged;
  final VoidCallback onAddSlot;
  final ValueChanged<int> onRemoveSlot;
  final _OpenScheduleSelectionSheet onOpenSelection;

  @override
  Widget build(BuildContext context) {
    final bool expanded = session.active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: expanded
          ? const EdgeInsets.all(14)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(expanded ? 22 : 20),
        border: Border.all(
          color: expanded
              ? (dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                    : AmanahColorTokens.neutral200)
              : Colors.transparent,
        ),
        boxShadow: expanded && !dark
            ? <BoxShadow>[
                BoxShadow(
                  color: AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onToggle(!expanded),
            child: Padding(
              padding: EdgeInsets.only(bottom: expanded ? 12 : 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          session.name,
                          style: TextStyle(
                            color: expanded
                                ? (dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral900)
                                : (dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral900),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        () {
                          final _SessionShiftBoundary bounds =
                              _getSessionShiftBoundary(session.id);
                          final String rangeStr = occupancy?.timeRange ??
                              '${bounds.defaultStart} - ${bounds.defaultEnd} WIB';
                          final String availabilityStr = occupancy != null
                              ? '${occupancy!.availableSlotsCount}/${occupancy!.totalSlots} Tersedia'
                              : '';
                          final String fullSubtitle =
                              availabilityStr.isNotEmpty
                                  ? '$rangeStr • $availabilityStr'
                                  : rangeStr;

                          return Text(
                            fullSubtitle,
                            style: TextStyle(
                              color: dark
                                  ? (expanded
                                        ? AmanahColorTokens.tabActiveDark
                                        : AmanahColorTokens.neutral400)
                                  : (expanded
                                        ? AmanahColorTokens.brand
                                        : AmanahColorTokens.neutral500),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }(),
                      ],
                    ),
                  ),
                  _ScheduleToggleSwitch(active: expanded, dark: dark),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    children: <Widget>[
                      for (int index = 0; index < session.slots.length; index++)
                        _AnimatedSlotEntry(
                          key: ValueKey<String>(session.slots[index].id),
                          child: _ScheduleSlotRow(
                            session: session,
                            slot: session.slots[index],
                            slotIndex: index,
                            occupancy: occupancy,
                            dark: dark,
                            showDivider: index > 0,
                            onOpenSelection: onOpenSelection,
                            onChanged: onSlotChanged,
                            onRemove: () => onRemoveSlot(index),
                          ),
                        ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onAddSlot,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: dark
                                ? AmanahColorTokens.pureWhite.withValues(
                                    alpha: 0.05,
                                  )
                                : AmanahColorTokens.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dark
                                  ? AmanahColorTokens.pureWhite.withValues(
                                      alpha: 0.10,
                                    )
                                  : AmanahColorTokens.neutral200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  color: dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSlotRow extends StatelessWidget {
  const _ScheduleSlotRow({
    required this.session,
    required this.slot,
    required this.slotIndex,
    this.occupancy,
    required this.dark,
    required this.showDivider,
    required this.onOpenSelection,
    required this.onChanged,
    required this.onRemove,
  });

  final _ScheduleFormSession session;
  final _ScheduleFormSlot slot;
  final int slotIndex;
  final ScheduleShiftOccupancy? occupancy;
  final bool dark;
  final bool showDivider;
  final _OpenScheduleSelectionSheet onOpenSelection;
  final _ScheduleSlotChanged onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                      : AmanahColorTokens.neutral300,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        Row(
          children: <Widget>[
            _SlotLabel(text: 'From', dark: dark),
            Expanded(
              child: _MiniSlotButton(
                value: slot.from,
                dark: dark,
                onTap: () {
                  final ScheduleContext? ctx = AmanahScheduleStore
                      .instance.scheduleContexts
                      .where((ScheduleContext c) =>
                          c.sessionShift == session.id ||
                          c.contextId == session.id)
                      .firstOrNull;
                  final _SessionShiftBoundary bounds =
                      _getSessionShiftBoundary(session.id, ctx);

                  final List<String> timeOptions;
                  final List<String> disabledTimes = <String>[];
                  final Map<String, String> subtitles = <String, String>{};

                  if (occupancy != null && occupancy!.slots.isNotEmpty) {
                    timeOptions = occupancy!.slots
                        .map((ScheduleShiftSlot s) => s.startTime)
                        .toList();
                    for (final ScheduleShiftSlot s in occupancy!.slots) {
                      if (!s.isAvailable) {
                        disabledTimes.add(s.startTime);
                        if (s.displayLabel.isNotEmpty) {
                          subtitles[s.startTime] = s.displayLabel;
                        }
                      }
                    }
                  } else {
                    timeOptions =
                        _getTimeOptionsForSession(session.id, context: ctx);
                  }

                  for (final _ScheduleFormSlot otherSlot in session.slots) {
                    if (otherSlot.id != slot.id && otherSlot.from.isNotEmpty) {
                      if (!disabledTimes.contains(otherSlot.from)) {
                        disabledTimes.add(otherSlot.from);
                        subtitles[otherSlot.from] = 'Antrean lain';
                      }
                    }
                  }

                  onOpenSelection(
                    title: 'Pilih Waktu Mulai (${session.name})',
                    subtitle:
                        'Batas shift: ${_formatMinutesToTime(bounds.startMinutes)} - ${_formatMinutesToTime(bounds.endMinutes)} WIB',
                    currentValue: slot.from,
                    options: timeOptions,
                    disabledOptions: disabledTimes,
                    optionSubtitles: subtitles,
                    sessionId: session.id,
                    isTimePicker: true,
                    onChanged: (String value) =>
                        onChanged(slotIndex: slotIndex, from: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            _SlotLabel(
              text: 'To',
              dark: dark,
            ),
            Expanded(
              child: _MiniSlotButton(
                value: slot.to,
                dark: dark,
                onTap: null,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onRemove,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AmanahColorTokens.neutral400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: <Widget>[
            Expanded(
              child: _SlotFieldColumn(
                label: 'Ruang Praktik',
                value: slot.room.isNotEmpty ? slot.room : 'Pilih Ruang Praktik',
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Ruang Praktik',
                  subtitle: 'Pilih ruangan praktik dokter',
                  currentValue: slot.room.isNotEmpty ? slot.room : 'Pilih Ruang Praktik',
                  options: kRoomOptions,
                  disabledOptions: const <String>[],
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, room: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SlotFieldColumn(
                label: 'Poli / Spesialisasi',
                value: slot.poli.isNotEmpty ? slot.poli : 'Pilih Poliklinik',
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Poli / Spesialisasi',
                  subtitle: 'Pilih poliklinik atau bidang spesialisasi',
                  currentValue: slot.poli.isNotEmpty ? slot.poli : 'Pilih Poliklinik',
                  options: kPoliOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, poli: value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SlotFieldColumn extends StatelessWidget {
  const _SlotFieldColumn({
    required this.label,
    required this.value,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral400
                : AmanahColorTokens.neutral500,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        _MiniSlotButton(value: value, dark: dark, onTap: onTap),
      ],
    );
  }
}

class _SlotLabel extends StatelessWidget {
  const _SlotLabel({
    required this.text,
    required this.dark,
  });

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: text == 'From' ? 34 : 20,
      child: Text(
        text,
        style: TextStyle(
          color: dark
              ? AmanahColorTokens.neutral400
              : AmanahColorTokens.neutral500,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniSlotButton extends StatelessWidget {
  const _MiniSlotButton({
    required this.value,
    required this.dark,
    this.onTap,
  });

  final String value;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: AmanahColorTokens.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleToggleSwitch extends StatelessWidget {
  const _ScheduleToggleSwitch({required this.active, required this.dark});

  final bool active;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active
            ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
            : (dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.20)
                  : AmanahColorTokens.neutral200),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AmanahColorTokens.surfaceLight,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AmanahColorTokens.pureBlack.withValues(alpha: 0.20),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmanahScheduleSelectionSheet extends StatefulWidget {
  const _AmanahScheduleSelectionSheet({
    required this.title,
    required this.subtitle,
    required this.currentValue,
    required this.options,
    this.disabledOptions = const <String>[],
    this.optionSubtitles = const <String, String>{},
    this.sessionId,
    this.isTimePicker = false,
  });

  final String title;
  final String subtitle;
  final String currentValue;
  final List<String> options;
  final List<String> disabledOptions;
  final Map<String, String> optionSubtitles;
  final String? sessionId;
  final bool isTimePicker;

  @override
  State<_AmanahScheduleSelectionSheet> createState() =>
      _AmanahScheduleSelectionSheetState();
}

class _AmanahScheduleSelectionSheetState
    extends State<_AmanahScheduleSelectionSheet> {
  late final TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String text) {
    if (!widget.isTimePicker || text.trim().isEmpty) {
      if (_validationError != null) {
        setState(() => _validationError = null);
      }
      return;
    }

    final ScheduleContext? ctx = widget.sessionId != null
        ? AmanahScheduleStore.instance.scheduleContexts
            .where((ScheduleContext c) =>
                c.sessionShift == widget.sessionId ||
                c.contextId == widget.sessionId)
            .firstOrNull
        : null;
    final int duration = ctx?.effectiveConsultationDurationMinutes ?? 30;
    final _SessionShiftBoundary bounds =
        _getSessionShiftBoundary(widget.sessionId ?? 'pagi', ctx);
    final int? minutes =
        _parseTimeToMinutes(text.trim(), sessionId: widget.sessionId);

    if (minutes == null) {
      setState(() {
        _validationError = 'Format waktu tidak valid (contoh: 08:30)';
      });
    } else if (minutes < bounds.startMinutes ||
        minutes > bounds.endMinutes - duration) {
      setState(() {
        _validationError =
            'Waktu harus dalam shift (${_formatMinutesToTime(bounds.startMinutes)} - ${_formatMinutesToTime(bounds.endMinutes)} WIB)';
      });
    } else {
      final String formatted = _formatMinutesToTime(minutes);
      final bool isOptionDisabled = widget.disabledOptions.any(
        (String d) => d.trim().toLowerCase() == formatted.toLowerCase(),
      );
      if (isOptionDisabled) {
        final String? reason = widget.optionSubtitles[formatted];
        setState(() {
          _validationError = reason != null && reason.isNotEmpty
              ? 'Waktu $formatted tidak tersedia: $reason'
              : 'Waktu $formatted sudah terisi atau tidak tersedia.';
        });
      } else if (_validationError != null) {
        setState(() => _validationError = null);
      }
    }
  }

  Future<void> _pickViaClock() async {
    final ScheduleContext? ctx = widget.sessionId != null
        ? AmanahScheduleStore.instance.scheduleContexts
            .where((ScheduleContext c) =>
                c.sessionShift == widget.sessionId ||
                c.contextId == widget.sessionId)
            .firstOrNull
        : null;
    final int duration = ctx?.effectiveConsultationDurationMinutes ?? 30;
    final _SessionShiftBoundary bounds =
        _getSessionShiftBoundary(widget.sessionId ?? 'pagi', ctx);
    final TimeOfDay initial = TimeOfDay(
      hour: (bounds.startMinutes ~/ 60).clamp(0, 23),
      minute: bounds.startMinutes % 60,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null && mounted) {
      final int pickedMinutes = picked.hour * 60 + picked.minute;
      if (pickedMinutes < bounds.startMinutes ||
          pickedMinutes > bounds.endMinutes - duration) {
        setState(() {
          _validationError =
              'Jam yang dipilih (${_formatMinutesToTime(pickedMinutes)}) di luar rentang shift (${_formatMinutesToTime(bounds.startMinutes)} - ${_formatMinutesToTime(bounds.endMinutes)} WIB)';
        });
        return;
      }

      final String formatted = _formatMinutesToTime(pickedMinutes);
      final bool isOptionDisabled = widget.disabledOptions.any(
        (String d) => d.trim().toLowerCase() == formatted.toLowerCase(),
      );
      if (isOptionDisabled) {
        final String? reason = widget.optionSubtitles[formatted];
        setState(() {
          _validationError = reason != null && reason.isNotEmpty
              ? 'Waktu $formatted tidak tersedia: $reason'
              : 'Waktu $formatted sudah terisi atau tidak tersedia.';
        });
        return;
      }

      Navigator.of(context).pop(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final String query = _controller.text.trim().toLowerCase();
    final List<String> filtered = widget.options
        .where((String option) => option.toLowerCase().contains(query))
        .toList();
    final Color selectedAccent = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.brand;
    final Color selectedForeground = dark
        ? AmanahColorTokens.canvasDark
        : AmanahColorTokens.surfaceLight;

    return AmanahBottomSheetScaffold(
      title: widget.title,
      subtitle: widget.subtitle.isEmpty ? null : widget.subtitle,
      fixedHeightFactor: 0.85,
      bodyPadding: EdgeInsets.zero,
      extendBodyBehindHeader: true,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AmanahSpacing.xxl,
          AmanahSpacing.lg,
          AmanahSpacing.xxl,
          AmanahSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.isTimePicker) ...<Widget>[
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: AmanahNoticeBanner(
                  message:
                      'Waktu selesai ("To") dihitung otomatis berdasarkan durasi konsultasi dokter hingga akhir shift.',
                  variant: AmanahNoticeVariant.info,
                ),
              ),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: dark
                          ? AmanahColorTokens.pureWhite.withValues(
                              alpha: 0.05,
                            )
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _validationError != null
                            ? AmanahColorTokens.danger
                            : (dark
                                  ? AmanahColorTokens.pureWhite.withValues(
                                      alpha: 0.15,
                                    )
                                  : AmanahColorTokens.neutral200),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (String val) {
                        _validateInput(val);
                        setState(() {});
                      },
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isTimePicker
                            ? 'Ketik jam mulai (cth. 08:45)...'
                            : 'Cari atau ketik manual...',
                        hintStyle: TextStyle(
                          color: dark
                              ? AmanahColorTokens.neutral500
                              : AmanahColorTokens.neutral400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          widget.isTimePicker
                              ? Icons.schedule_rounded
                              : Icons.search_rounded,
                          size: 16,
                          color: AmanahColorTokens.neutral400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_controller.text.trim().isNotEmpty &&
                    _validationError == null) ...<Widget>[
                  const SizedBox(width: 8),
                  AmanahButton.primary(
                    text: 'Gunakan',
                    size: AmanahButtonSize.small,
                    onPressed: () {
                      final String raw = _controller.text.trim();
                      if (widget.isTimePicker) {
                        final int? parsed = _parseTimeToMinutes(
                          raw,
                          sessionId: widget.sessionId,
                        );
                        if (parsed != null) {
                          Navigator.of(context).pop(
                            _formatMinutesToTime(parsed),
                          );
                          return;
                        }
                      }
                      Navigator.of(context).pop(raw);
                    },
                  ),
                ],
                if (widget.isTimePicker) ...<Widget>[
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _pickViaClock,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                                .withValues(alpha: 0.08)
                            : AmanahColorTokens.surfaceSecondaryLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                                  .withValues(alpha: 0.15)
                              : AmanahColorTokens.neutral200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: dark
                                ? AmanahColorTokens.tabActiveDark
                                : AmanahColorTokens.brand,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Jam',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? AmanahColorTokens.tabActiveDark
                                  : AmanahColorTokens.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_validationError != null) ...<Widget>[
              const SizedBox(height: 5),
              Text(
                _validationError!,
                style: const TextStyle(
                  color: AmanahColorTokens.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              widget.isTimePicker ? 'Pilihan Cepat Sesi' : 'Pilihan Tersedia',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada pilihan ditemukan',
                        style: TextStyle(
                          color: AmanahColorTokens.neutral400,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent:
                                widget.optionSubtitles.isNotEmpty ? 52 : 44,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        final String option = filtered[index];
                        final bool isSelected =
                            widget.currentValue.trim().toLowerCase() ==
                            option.trim().toLowerCase();
                        final bool isDisabled =
                            !isSelected &&
                            widget.disabledOptions.any(
                              (String d) =>
                                  d.trim().toLowerCase() ==
                                  option.trim().toLowerCase(),
                            );
                        final String? subtitle = widget.optionSubtitles[option];

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isDisabled
                              ? null
                              : () => Navigator.of(context).pop(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedAccent
                                  : isDisabled
                                  ? (dark
                                        ? AmanahColorTokens.pureWhite
                                              .withValues(alpha: 0.02)
                                        : AmanahColorTokens.neutral100)
                                  : (dark
                                        ? AmanahColorTokens.pureWhite
                                              .withValues(alpha: 0.05)
                                        : AmanahColorTokens.surfaceLight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? selectedAccent
                                    : (dark
                                          ? AmanahColorTokens.pureWhite
                                                .withValues(alpha: 0.10)
                                          : AmanahColorTokens.neutral200),
                              ),
                              boxShadow: isSelected
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: selectedAccent.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        option,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isSelected
                                              ? selectedForeground
                                              : isDisabled
                                              ? (dark
                                                    ? AmanahColorTokens
                                                          .neutral600
                                                    : AmanahColorTokens
                                                          .neutral400)
                                              : (dark
                                                    ? AmanahColorTokens
                                                          .pureWhite
                                                    : AmanahColorTokens
                                                          .neutral900),
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                        ),
                                      ),
                                      if (subtitle != null &&
                                          subtitle.isNotEmpty) ...<Widget>[
                                        const SizedBox(height: 2),
                                        Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isSelected
                                                ? selectedForeground
                                                      .withValues(alpha: 0.8)
                                                : (dark
                                                      ? AmanahColorTokens
                                                            .neutral500
                                                      : AmanahColorTokens
                                                            .neutral400),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 15,
                                    color: selectedForeground,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
