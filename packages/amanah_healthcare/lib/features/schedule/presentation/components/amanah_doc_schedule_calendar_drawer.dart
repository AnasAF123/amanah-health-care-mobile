import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

/// Monthly Doctor Schedule Big Calendar Drawer Modal ("Lihat Schedule")
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
  DateTime _currentMonth = DateTime.now();

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
                  color: dark
                      ? AmanahColorTokens.surfaceLight
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
                  ? AmanahColorTokens.surfaceLight
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
