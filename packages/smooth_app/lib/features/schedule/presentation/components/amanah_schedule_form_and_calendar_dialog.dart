import 'package:flutter/material.dart';
import 'package:smooth_app/features/schedule/data/amanah_schedule_store.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

const List<String> kTimeOptions = <String>[
  '12:00 AM',
  '1:00 AM',
  '2:00 AM',
  '3:00 AM',
  '4:00 AM',
  '5:00 AM',
  '6:00 AM',
  '7:00 AM',
  '8:00 AM',
  '9:00 AM',
  '10:00 AM',
  '11:00 AM',
  '12:00 PM',
  '1:00 PM',
  '2:00 PM',
  '3:00 PM',
  '4:00 PM',
  '5:00 PM',
  '6:00 PM',
  '7:00 PM',
  '8:00 PM',
  '9:00 PM',
  '10:00 PM',
  '11:00 PM',
];

const List<String> kRoomOptions = <String>[
  'Ruang 101',
  'Ruang 102',
  'Ruang 201',
  'Ruang 202',
  'Ruang 203',
  'Ruang 204',
  'Ruang 301',
  'Ruang 302',
  'Ruang VIP 1',
  'Ruang VIP 2',
  'Ruang Bedah A',
  'Ruang Konsultasi 1',
  'Ruang Radiologi',
  'Ruang Tindakan 2',
  'Suite VIP 01',
  'Suite VIP 02',
  'Studio D-02',
];

const List<String> kPoliOptions = <String>[
  'Poli Gigi & Mulut',
  'Poli Gigi Umum',
  'Poli Umum',
  'Poli Spesialis Anak',
  'Poli Penyakit Dalam',
  'Poli Jantung & Pembuluh',
  'Poli Mata',
  'Poli THT',
  'Poli Kulit & Kelamin',
  'Poli Syaraf',
  'Poli Kandungan (Obgyn)',
  'Poli Bedah Umum',
  'Poli Fisioterapi',
  'Klinik Spesialis Konservasi',
  'Spesialis Bedah Mulut',
  'Telemedisin Gigi',
  'Poli Eksekutif VIP',
  'Klinik Eksekutif VIP',
];

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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  DateTime _currentMonth = DateTime(2026, 8);

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
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

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.20)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Kalender Jadwal Praktik',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

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
                },
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'PlusJakartaSans',
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
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Days Header (Min, Sen, Sel, ...)
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

          // Month Days Grid
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
              Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
              Color? dotColor;

              if (isSelected) {
                bgColor = isCuti
                    ? const Color(0xFFF59E0B)
                    : (dark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0A44FF));
                textColor = (isCuti && dark) ? Colors.black : Colors.white;
              } else if (isToday) {
                bgColor =
                    (dark ? const Color(0xFF38BDF8) : const Color(0xFF0A44FF))
                        .withValues(alpha: 0.15);
                textColor = dark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0A44FF);
                dotColor = dark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0A44FF);
              } else if (isPast) {
                textColor = dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFFCBD5E1);
              } else if (isCuti) {
                dotColor = const Color(0xFFF59E0B);
              } else if (hasSchedules) {
                dotColor = const Color(0xFF10B981);
              } else {
                dotColor = dark
                    ? const Color(0xFF64748B)
                    : const Color(0xFFCBD5E1);
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
                          fontFamily: 'PlusJakartaSans',
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
          const Wrap(
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              _CalendarLegendDot(color: Color(0xFF0A44FF), label: 'Hari ini'),
              _CalendarLegendDot(color: Color(0xFF10B981), label: 'Ada sesi'),
              _CalendarLegendDot(color: Color(0xFFF59E0B), label: 'Cuti'),
              _CalendarLegendDot(color: Color(0xFF94A3B8), label: 'Tutup'),
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
            color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontFamily: 'PlusJakartaSans',
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
          color: Color(0xFF94A3B8),
          fontFamily: 'PlusJakartaSans',
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  DateTime _selectedDate = DateTime(2026, 8, 26);
  DateTime _calendarMonth = DateTime(2026, 8);
  bool _isCalendarOpen = false;
  String _status = 'Buka'; // 'Menunggu', 'Buka', 'Cuti'
  List<_ScheduleFormSession> _sessions = const <_ScheduleFormSession>[];

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
      _status = 'Menunggu';
      _sessions = _buildInitialSessions();
    }
  }

  List<_ScheduleFormSession> _buildInitialSessions({
    DoctorSchedule? editingSchedule,
  }) {
    final String matchedId = editingSchedule == null
        ? ''
        : _sessionIdFromType(editingSchedule.sessionType);
    return <_ScheduleFormSession>[
      _ScheduleFormSession(
        id: 'dini_hari',
        name: 'Sesi Dini Hari',
        sessionType: 'Dini Hari',
        active: matchedId == 'dini_hari',
        slots: <_ScheduleFormSlot>[
          _ScheduleFormSlot(
            id: 'dh1',
            from: matchedId == 'dini_hari'
                ? (editingSchedule?.startTime ?? '1:00 AM')
                : '1:00 AM',
            to: matchedId == 'dini_hari'
                ? (editingSchedule?.endTime ?? '4:00 AM')
                : '4:00 AM',
            room: editingSchedule?.room ?? 'Ruang 201',
            poli: editingSchedule?.poli ?? 'Poli Gigi & Mulut',
          ),
        ],
      ),
      _ScheduleFormSession(
        id: 'pagi',
        name: 'Sesi Pagi',
        sessionType: 'Pagi',
        active: matchedId == 'pagi',
        slots: <_ScheduleFormSlot>[
          _ScheduleFormSlot(
            id: 'p1',
            from: matchedId == 'pagi'
                ? (editingSchedule?.startTime ?? '7:00 AM')
                : '7:00 AM',
            to: matchedId == 'pagi'
                ? (editingSchedule?.endTime ?? '11:00 AM')
                : '11:00 AM',
            room: editingSchedule?.room ?? 'Ruang 201',
            poli: editingSchedule?.poli ?? 'Poli Gigi & Mulut',
          ),
        ],
      ),
      _ScheduleFormSession(
        id: 'siang',
        name: 'Sesi Siang',
        sessionType: 'Siang',
        active: matchedId == 'siang',
        slots: <_ScheduleFormSlot>[
          _ScheduleFormSlot(
            id: 's1',
            from: matchedId == 'siang'
                ? (editingSchedule?.startTime ?? '1:00 PM')
                : '1:00 PM',
            to: matchedId == 'siang'
                ? (editingSchedule?.endTime ?? '5:00 PM')
                : '5:00 PM',
            room: editingSchedule?.room ?? 'Ruang 201',
            poli: editingSchedule?.poli ?? 'Poli Gigi & Mulut',
          ),
        ],
      ),
      _ScheduleFormSession(
        id: 'malam',
        name: 'Sesi Malam',
        sessionType: 'Malam',
        active: matchedId == 'malam',
        slots: <_ScheduleFormSlot>[
          _ScheduleFormSlot(
            id: 'm1',
            from: matchedId == 'malam'
                ? (editingSchedule?.startTime ?? '7:00 PM')
                : '7:00 PM',
            to: matchedId == 'malam'
                ? (editingSchedule?.endTime ?? '10:00 PM')
                : '10:00 PM',
            room: editingSchedule?.room ?? 'Ruang 201',
            poli: editingSchedule?.poli ?? 'Poli Gigi & Mulut',
          ),
        ],
      ),
    ];
  }

  void _saveSchedule() {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String dateStr =
        '${_getDayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}';
    final List<_ScheduleFormSession> activeSessions = _sessions
        .where((_ScheduleFormSession session) => session.active)
        .toList();
    final List<_ScheduleFormSession> targetSessions = activeSessions.isNotEmpty
        ? activeSessions
        : <_ScheduleFormSession>[
            _sessions.firstWhere(
              (_ScheduleFormSession session) => session.id == 'pagi',
              orElse: () => _buildInitialSessions()[1],
            ),
          ];
    final _ScheduleFormSession firstActive = targetSessions.first;
    final _ScheduleFormSlot firstSlot = firstActive.slots.isNotEmpty
        ? firstActive.slots.first
        : const _ScheduleFormSlot(
            id: 'fallback',
            from: '7:00 AM',
            to: '11:00 AM',
            room: 'Ruang 201',
            poli: 'Poli Gigi & Mulut',
          );
    final String timeStr = '${firstSlot.from} - ${firstSlot.to} WIB';

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
        badge: _status,
        badgeVariant: _status == 'Cuti'
            ? AmanahBadgeVariant.warning
            : (_status == 'Menunggu'
                  ? AmanahBadgeVariant.primary
                  : AmanahBadgeVariant.success),
      );
      store.updateSchedule(_selectedDate, updated);
      if (_status == 'Cuti') {
        store.setDayCuti(_selectedDate, true);
      }
    } else {
      for (int index = 0; index < targetSessions.length; index++) {
        final _ScheduleFormSession session = targetSessions[index];
        final _ScheduleFormSlot slot = session.slots.isNotEmpty
            ? session.slots.first
            : const _ScheduleFormSlot(
                id: 'fallback',
                from: '7:00 AM',
                to: '11:00 AM',
                room: 'Ruang 201',
                poli: 'Poli Gigi & Mulut',
              );
        final DoctorSchedule newSch = DoctorSchedule(
          id: 'ses-${DateTime.now().millisecondsSinceEpoch}-${session.id}-$index',
          title: session.name,
          date: dateStr,
          time: '${slot.from} - ${slot.to} WIB',
          startTime: slot.from,
          endTime: slot.to,
          sessionType: session.sessionType,
          poli: slot.poli,
          room: slot.room,
          slotCount: '0',
          slotText: '0 Pasien Booking',
          badge: 'Menunggu',
          badgeVariant: AmanahBadgeVariant.primary,
          bookedPatients: const <BookedPatient>[],
        );
        store.addSchedule(_selectedDate, newSch);
      }
    }
    widget.onSavedDate?.call(_selectedDate);
    Navigator.of(context).pop();
  }

  void _deleteSchedule() {
    if (widget.scheduleToEdit != null) {
      AmanahScheduleStore.instance.deleteSchedule(
        _selectedDate,
        widget.scheduleToEdit!.id,
      );
    }
    Navigator.of(context).pop();
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
    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession session) {
        if (session.id != sessionId) {
          return session;
        }
        final _ScheduleFormSlot previousSlot = session.slots.isNotEmpty
            ? session.slots.last
            : _defaultSlotForSession(session.id);
        final _ScheduleFormSlot defaultSlot = _defaultSlotForSession(
          session.id,
          id: '${session.id}-${DateTime.now().microsecondsSinceEpoch}',
        );
        return session.copyWith(
          slots: <_ScheduleFormSlot>[
            ...session.slots,
            _ScheduleFormSlot(
              id: defaultSlot.id,
              from: defaultSlot.from,
              to: defaultSlot.to,
              room: previousSlot.room,
              poli: previousSlot.poli,
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
    setState(() {
      _sessions = _sessions.map((_ScheduleFormSession session) {
        if (session.id != sessionId) {
          return session;
        }
        final List<_ScheduleFormSlot> slots = <_ScheduleFormSlot>[
          for (int i = 0; i < session.slots.length; i++)
            i == slotIndex
                ? session.slots[i].copyWith(
                    from: from,
                    to: to,
                    room: room,
                    poli: poli,
                  )
                : session.slots[i],
        ];
        return session.copyWith(slots: slots);
      }).toList();
    });
  }

  _ScheduleFormSlot _defaultSlotForSession(String sessionId, {String? id}) {
    if (sessionId == 'dini_hari') {
      return _ScheduleFormSlot(
        id: id ?? 'dh-${DateTime.now().microsecondsSinceEpoch}',
        from: '2:00 AM',
        to: '4:00 AM',
        room: 'Ruang 201',
        poli: 'Poli Gigi & Mulut',
      );
    }
    if (sessionId == 'siang') {
      return _ScheduleFormSlot(
        id: id ?? 's-${DateTime.now().microsecondsSinceEpoch}',
        from: '2:00 PM',
        to: '4:00 PM',
        room: 'Ruang 201',
        poli: 'Poli Gigi & Mulut',
      );
    }
    if (sessionId == 'malam') {
      return _ScheduleFormSlot(
        id: id ?? 'm-${DateTime.now().microsecondsSinceEpoch}',
        from: '8:00 PM',
        to: '10:00 PM',
        room: 'Ruang 201',
        poli: 'Poli Gigi & Mulut',
      );
    }
    return _ScheduleFormSlot(
      id: id ?? 'p-${DateTime.now().microsecondsSinceEpoch}',
      from: '8:00 AM',
      to: '10:00 AM',
      room: 'Ruang 201',
      poli: 'Poli Gigi & Mulut',
    );
  }

  Future<void> _openSelectionSheet({
    required String title,
    required String subtitle,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _AmanahScheduleSelectionSheet(
        title: title,
        subtitle: subtitle,
        currentValue: currentValue,
        options: options,
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

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.92,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE5E7EB),
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 45,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.20)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF0F172A),
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Tanggal Praktik',
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 16),

            if (isEditing) ...<Widget>[
              Text(
                'Status Praktik',
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: <String>['Menunggu', 'Buka', 'Cuti'].map((
                    String s,
                  ) {
                    final bool active = _status == s;
                    Color pillBg = Colors.transparent;
                    Color pillText = dark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B);

                    if (active) {
                      if (s == 'Buka') {
                        pillBg = const Color(0xFF10B981);
                        pillText = Colors.white;
                      } else if (s == 'Cuti') {
                        pillBg = const Color(0xFFE11D48);
                        pillText = Colors.white;
                      } else {
                        pillBg = const Color(0xFF0A44FF);
                        pillText = Colors.white;
                      }
                    }

                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: pillBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: active ? Colors.white : pillText,
                                  shape: BoxShape.circle,
                                ),
                                child: const SizedBox(width: 6, height: 6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s,
                                style: TextStyle(
                                  color: pillText,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
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
              const SizedBox(height: 16),
            ],

            Text(
              'Sesi Praktik & Jam',
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: <Widget>[
                for (final _ScheduleFormSession session
                    in _sessions) ...<Widget>[
                  _ScheduleSessionPanel(
                    session: session,
                    dark: dark,
                    onToggle: (bool value) => _toggleSession(session.id, value),
                    onSlotChanged:
                        ({
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
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // 5. Actions (Simpan, Batal, Hapus)
            Row(
              children: <Widget>[
                if (isEditing) ...<Widget>[
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      foregroundColor: const Color(0xFFE11D48),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: _deleteSchedule,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _ScheduleDrawerActionButton(
                    label: 'Batal',
                    dark: dark,
                    variant: _ScheduleActionVariant.outline,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScheduleDrawerActionButton(
                    label: isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
                    dark: dark,
                    variant: _ScheduleActionVariant.primary,
                    onTap: _saveSchedule,
                  ),
                ),
              ],
            ),
          ],
        ),
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
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC),
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
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                    fontFamily: 'PlusJakartaSans',
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
                  ? (dark ? Colors.white : const Color(0xFF0F172A))
                  : (dark ? const Color(0xFF52525B) : const Color(0xFFCBD5E1));
              if (isSelected) {
                bgColor = dark
                    ? const Color(0xFF22D3EE)
                    : const Color(0xFF2563EB);
                textColor = dark ? const Color(0xFF083344) : Colors.white;
              } else if (isToday) {
                bgColor = dark
                    ? const Color(0xFF22D3EE).withValues(alpha: 0.15)
                    : const Color(0xFFEFF6FF);
                textColor = dark
                    ? const Color(0xFF22D3EE)
                    : const Color(0xFF2563EB);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() {
                  _selectedDate = date;
                  _calendarMonth = DateTime(date.year, date.month);
                  _isCalendarOpen = false;
                }),
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
                                          ? const Color(0xFF22D3EE)
                                          : const Color(0xFF2563EB))
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
                      fontFamily: 'PlusJakartaSans',
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
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.05))
        : (expanded ? const Color(0xFFE2E8F0) : const Color(0xFFF8FAFC));
    final Color iconBackground = dark
        ? const Color(0xFF172554).withValues(alpha: 0.60)
        : const Color(0xFFEFF6FF);
    final Color accent = dark
        ? const Color(0xFF22D3EE)
        : const Color(0xFF2563EB);

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
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'PlusJakartaSans',
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
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ScheduleActionVariant { outline, primary }

class _ScheduleDrawerActionButton extends StatefulWidget {
  const _ScheduleDrawerActionButton({
    required this.label,
    required this.dark,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final bool dark;
  final _ScheduleActionVariant variant;
  final VoidCallback onTap;

  @override
  State<_ScheduleDrawerActionButton> createState() =>
      _ScheduleDrawerActionButtonState();
}

class _ScheduleDrawerActionButtonState
    extends State<_ScheduleDrawerActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool primary = widget.variant == _ScheduleActionVariant.primary;
    final Color background = primary
        ? (widget.dark ? const Color(0xFF22D3EE) : const Color(0xFF2563EB))
        : Colors.transparent;
    final Color foreground = primary
        ? (widget.dark ? const Color(0xFF083344) : Colors.white)
        : (widget.dark ? const Color(0xFFD4D4D8) : const Color(0xFF334155));
    final Border? border = primary
        ? null
        : Border.all(
            color: widget.dark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFE2E8F0),
          );
    final List<BoxShadow>? shadow = primary
        ? <BoxShadow>[
            BoxShadow(
              color:
                  (widget.dark
                          ? const Color(0xFF22D3EE)
                          : const Color(0xFF2563EB))
                      .withValues(alpha: widget.dark ? 0.20 : 0.30),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ]
        : null;

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        scale: _pressed ? 0.98 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            height: 42,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: border,
              boxShadow: shadow,
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
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
    required this.dark,
    required this.onToggle,
    required this.onSlotChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onOpenSelection,
  });

  final _ScheduleFormSession session;
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
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(expanded ? 22 : 20),
        border: Border.all(
          color: expanded
              ? (dark
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFE2E8F0))
              : Colors.transparent,
        ),
        boxShadow: expanded && !dark
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
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
                    child: Text(
                      session.name,
                      style: TextStyle(
                        color: expanded
                            ? (dark ? Colors.white : const Color(0xFF0F172A))
                            : (dark
                                  ? const Color(0xFFD4D4D8)
                                  : const Color(0xFF334155)),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
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
                            slot: session.slots[index],
                            slotIndex: index,
                            dark: dark,
                            showDivider: index > 0,
                            onOpenSelection: onOpenSelection,
                            onChanged: onSlotChanged,
                            onRemove: () => onRemoveSlot(index),
                          ),
                        ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onAddSlot,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Icon(Icons.add_rounded, size: 17),
                              const SizedBox(width: 6),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  color: dark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontFamily: 'PlusJakartaSans',
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
    required this.slot,
    required this.slotIndex,
    required this.dark,
    required this.showDivider,
    required this.onOpenSelection,
    required this.onChanged,
    required this.onRemove,
  });

  final _ScheduleFormSlot slot;
  final int slotIndex;
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
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFCBD5E1),
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
                onTap: () => onOpenSelection(
                  title: 'Pilih Jam Mulai',
                  subtitle: 'Jam awal sesi praktik dokter',
                  currentValue: slot.from,
                  options: kTimeOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, from: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SlotLabel(text: 'To', dark: dark),
            Expanded(
              child: _MiniSlotButton(
                value: slot.to,
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Jam Selesai',
                  subtitle: 'Jam akhir sesi praktik dokter',
                  currentValue: slot.to,
                  options: kTimeOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, to: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onRemove,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: dark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF94A3B8),
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
                value: slot.room,
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Ruang Praktik',
                  subtitle: 'Lokasi sesi dokter berlangsung',
                  currentValue: slot.room,
                  options: kRoomOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, room: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SlotFieldColumn(
                label: 'Poli / Spesialisasi',
                value: slot.poli,
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Poli / Spesialisasi',
                  subtitle: 'Unit layanan untuk sesi praktik',
                  currentValue: slot.poli,
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
            color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
            fontFamily: 'PlusJakartaSans',
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
  const _SlotLabel({required this.text, required this.dark});

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: text == 'From' ? 34 : 20,
      child: Text(
        text,
        style: TextStyle(
          color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
          fontFamily: 'PlusJakartaSans',
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
    required this.onTap,
  });

  final String value;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFE2E8F0),
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
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15,
              color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF94A3B8),
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
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: 42,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active
            ? (dark ? const Color(0xFF22D3EE) : const Color(0xFF2563EB))
            : (dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: active && dark ? const Color(0xFF083344) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
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
  });

  final String title;
  final String subtitle;
  final String currentValue;
  final List<String> options;

  @override
  State<_AmanahScheduleSelectionSheet> createState() =>
      _AmanahScheduleSelectionSheetState();
}

class _AmanahScheduleSelectionSheetState
    extends State<_AmanahScheduleSelectionSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String query = _controller.text.toLowerCase();
    final List<String> filtered = widget.options
        .where((String option) => option.toLowerCase().contains(query))
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.78,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0A0E1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.20)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: dark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF0F172A),
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Cari atau ketik manual',
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _controller.text.trim().isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () {
                        Navigator.of(context).pop(_controller.text.trim());
                      },
                    )
                  : null,
              filled: true,
              fillColor: dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 48,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (BuildContext context, int index) {
                final String option = filtered[index];
                final bool selected = option == widget.currentValue;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context).pop(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0A44FF)
                          : (dark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF0A44FF)
                            : (dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            option,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : (dark
                                        ? Colors.white
                                        : const Color(0xFF0F172A)),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (selected) ...<Widget>[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
