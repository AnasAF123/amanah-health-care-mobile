import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
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

const List<String> kOccupiedTimeOptions = <String>[
  '2:00 AM',
  '3:00 AM',
  '9:00 AM',
  '10:00 AM',
  '2:00 PM',
  '3:00 PM',
  '8:00 PM',
];

const List<String> kOccupiedRoomOptions = <String>[
  'Ruang 102',
  'Ruang 203',
  'Ruang VIP 1',
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
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : (isCuti
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF0A44FF));
                textColor = dark ? AmanahColorTokens.canvasDark : Colors.white;
              } else if (isToday) {
                bgColor =
                    (dark
                            ? AmanahColorTokens.tabActiveDark
                            : const Color(0xFF0A44FF))
                        .withValues(alpha: 0.15);
                textColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : const Color(0xFF0A44FF);
                dotColor = dark
                    ? AmanahColorTokens.tabActiveDark
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              _CalendarLegendDot(
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : const Color(0xFF0A44FF),
                label: 'Hari ini',
              ),
              const _CalendarLegendDot(
                color: Color(0xFF10B981),
                label: 'Ada sesi',
              ),
              const _CalendarLegendDot(color: Color(0xFFF59E0B), label: 'Cuti'),
              const _CalendarLegendDot(
                color: Color(0xFF94A3B8),
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
    List<String> disabledOptions = const <String>[],
  }) async {
    final String? selected = await showAmanahBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => _AmanahScheduleSelectionSheet(
        title: title,
        subtitle: subtitle,
        currentValue: currentValue,
        options: options,
        disabledOptions: disabledOptions,
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
          // 0. Status Jadwal Praktik: Menunggu | Buka | Cuti (Only displayed when editing)
          if (isEditing) ...<Widget>[
            Text(
              'Status Praktik',
              style: TextStyle(
                color: dark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children:
                    <Map<String, dynamic>>[
                      <String, dynamic>{
                        'label': 'Menunggu',
                        'activeBg': const Color(0xFFF59E0B),
                        'activeText': Colors.white,
                        'dotColor': const Color(0xFFFBBF24),
                      },
                      <String, dynamic>{
                        'label': 'Buka',
                        'activeBg': const Color(0xFF059669),
                        'activeText': Colors.white,
                        'dotColor': const Color(0xFF34D399),
                      },
                      <String, dynamic>{
                        'label': 'Cuti',
                        'activeBg': const Color(0xFFE11D48),
                        'activeText': Colors.white,
                        'dotColor': const Color(0xFFFB7185),
                      },
                    ].map((Map<String, dynamic> item) {
                      final String label = item['label'] as String;
                      final bool active = _status == label;
                      final Color activeBg = item['activeBg'] as Color;
                      final Color activeText = item['activeText'] as Color;
                      final Color dotColor = item['dotColor'] as Color;
                      final Color selectedBg = dark
                          ? AmanahColorTokens.tabActiveDark
                          : activeBg;
                      final Color selectedText = dark
                          ? AmanahColorTokens.canvasDark
                          : activeText;

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
                                        color: selectedBg.withValues(
                                          alpha: 0.25,
                                        ),
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
                                              ? const Color(0xFFA1A1AA)
                                              : const Color(0xFF475569)),
                                    fontFamily: 'PlusJakartaSans',
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

          // 1. Tanggal Praktik (Date Picker)
          Text(
            'Tanggal Praktik',
            style: TextStyle(
              color: dark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              fontFamily: 'PlusJakartaSans',
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

          // 2. Sesi Praktik & Jam
          Text(
            'Sesi Praktik & Jam',
            style: TextStyle(
              color: dark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: <Widget>[
              for (final _ScheduleFormSession session in _sessions) ...<Widget>[
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
                    ? AmanahColorTokens.tabActiveDark
                    : const Color(0xFF2563EB);
                textColor = dark ? AmanahColorTokens.canvasDark : Colors.white;
              } else if (isToday) {
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.15)
                    : const Color(0xFFEFF6FF);
                textColor = dark
                    ? AmanahColorTokens.tabActiveDark
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
                                          ? AmanahColorTokens.tabActiveDark
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
        ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.12)
        : const Color(0xFFEFF6FF);
    final Color accent = dark
        ? AmanahColorTokens.tabActiveDark
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
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
                        borderRadius: BorderRadius.circular(12),
                        onTap: onAddSlot,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: dark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
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
                  title: 'Pilih Waktu Mulai (From)',
                  subtitle: 'Pilih jam dari daftar atau ketik manual',
                  currentValue: slot.from,
                  options: kTimeOptions,
                  disabledOptions: kOccupiedTimeOptions,
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
                  title: 'Pilih Waktu Selesai (To)',
                  subtitle: 'Pilih jam dari daftar atau ketik manual',
                  currentValue: slot.to,
                  options: kTimeOptions,
                  disabledOptions: kOccupiedTimeOptions,
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
                  size: 16,
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
                  subtitle: 'Pilih ruangan praktik dokter',
                  currentValue: slot.room,
                  options: kRoomOptions,
                  disabledOptions: kOccupiedRoomOptions,
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
                  subtitle: 'Pilih poliklinik atau bidang spesialisasi',
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
                  fontWeight: FontWeight.w700,
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active
            ? (dark ? AmanahColorTokens.tabActiveDark : const Color(0xFF0D66E9))
            : (dark
                  ? Colors.white.withValues(alpha: 0.20)
                  : const Color(0xFFE5E5EA)),
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
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
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
  });

  final String title;
  final String subtitle;
  final String currentValue;
  final List<String> options;
  final List<String> disabledOptions;

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
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final String query = _controller.text.trim().toLowerCase();
    final List<String> filtered = widget.options
        .where((String option) => option.toLowerCase().contains(query))
        .toList();
    final Color selectedAccent = dark
        ? AmanahColorTokens.tabActiveDark
        : const Color(0xFF2563EB);
    final Color selectedForeground = dark
        ? AmanahColorTokens.canvasDark
        : Colors.white;

    return AmanahBottomSheetScaffold(
      title: widget.title,
      subtitle: widget.subtitle.isEmpty ? null : widget.subtitle,
      fixedHeightFactor: 0.82,
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
            // Search & Manual Entry Form
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari atau ketik manual...',
                        hintStyle: TextStyle(
                          color: dark
                              ? const Color(0xFF71717A)
                              : const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: dark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF94A3B8),
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
                if (_controller.text.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(width: 8),
                  AmanahButton.primary(
                    text: 'Gunakan',
                    size: AmanahButtonSize.small,
                    onPressed: () {
                      Navigator.of(context).pop(_controller.text.trim());
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            Text(
              'Pilihan Tersedia',
              style: TextStyle(
                color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Options Grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada pilihan ditemukan',
                        style: TextStyle(
                          color: dark
                              ? const Color(0xFFA1A1AA)
                              : const Color(0xFF94A3B8),
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 44,
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

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isDisabled
                              ? null
                              : () => Navigator.of(context).pop(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedAccent
                                  : isDisabled
                                  ? (dark
                                        ? Colors.white.withValues(alpha: 0.02)
                                        : const Color(0xFFF1F5F9))
                                  : (dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? selectedAccent
                                    : (dark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : const Color(0xFFE2E8F0)),
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
                                  child: Text(
                                    option,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected
                                          ? selectedForeground
                                          : isDisabled
                                          ? (dark
                                                ? const Color(0xFF52525B)
                                                : const Color(0xFF94A3B8))
                                          : (dark
                                                ? Colors.white
                                                : const Color(0xFF0F172A)),
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
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
