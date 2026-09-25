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

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.canvasDark
            : AmanahColorTokens.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral200,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        24 + MediaQuery.viewPaddingOf(context).bottom,
      ),
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
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.20)
                    : AmanahColorTokens.neutral300,
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
                    color: dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral900,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
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
              CalendarDayHeader('Min'),
              CalendarDayHeader('Sen'),
              CalendarDayHeader('Sel'),
              CalendarDayHeader('Rab'),
              CalendarDayHeader('Kam'),
              CalendarDayHeader('Jum'),
              CalendarDayHeader('Sab'),
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

              final String dateKey =
                  '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final CalendarDaySummary? backendDay = store.calendarSummariesMap[dateKey];

              final DayScheduleSetting setting = store.getDaySettingForDate(date);
              final bool isCuti = (backendDay?.isCuti ?? false) || setting.isCuti;
              final bool isClosed = (backendDay?.isClosed ?? false) || setting.isDayClosed;
              final List<DoctorSchedule> schedules = store.getSchedulesForDate(date);
              final bool hasSchedules = (backendDay?.hasSchedule ?? false) || schedules.isNotEmpty;

              Color bgColor = Colors.transparent;
              Color textColor = dark
                  ? AmanahColorTokens.pureWhite
                  : AmanahColorTokens.neutral900;
              Color? dotColor;

              if (isSelected) {
                bgColor = dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand;
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
                if (hasSchedules) {
                  dotColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral400;
                }
              } else if (isCuti) {
                dotColor = AmanahColorTokens.warning;
              } else if (isClosed) {
                dotColor = AmanahColorTokens.neutral400;
              } else if (hasSchedules) {
                dotColor = AmanahColorTokens.success;
              } else {
                dotColor = dark
                    ? AmanahColorTokens.neutral500
                    : AmanahColorTokens.neutral300;
              }

              final bool isClickable = !isPast || hasSchedules;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isClickable
                    ? () {
                        widget.onSelectDate(date);
                        Navigator.of(context).pop();
                      }
                    : null,
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
              CalendarLegendDot(
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
                label: 'Hari ini',
              ),
              const CalendarLegendDot(
                color: AmanahColorTokens.success,
                label: 'Ada sesi',
              ),
              CalendarLegendDot(
                color: AmanahColorTokens.warning,
                label: ScheduleFormConstants.statusCuti,
              ),
              CalendarLegendDot(
                color: AmanahColorTokens.neutral400,
                label: ScheduleFormConstants.statusTutup,
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

class CalendarLegendDot extends StatelessWidget {
  const CalendarLegendDot({required this.color, required this.label, super.key});

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

class CalendarDayHeader extends StatelessWidget {
  const CalendarDayHeader(this.text, {super.key});
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
