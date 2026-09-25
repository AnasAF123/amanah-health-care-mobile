import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/dialogs/amanah_doc_schedule_calendar_drawer.dart';

class ScheduleSelectorButton extends StatelessWidget {
  const ScheduleSelectorButton({
    required this.value,
    required this.icon,
    required this.dark,
    required this.onTap,
    this.expanded = false,
    super.key,
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

class ScheduleFormInlineCalendar extends StatelessWidget {
  const ScheduleFormInlineCalendar({
    required this.calendarMonth,
    required this.selectedDate,
    required this.dark,
    required this.onMonthChanged,
    required this.onSelectDate,
    super.key,
  });

  final DateTime calendarMonth;
  final DateTime selectedDate;
  final bool dark;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelectDate;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  @override
  Widget build(BuildContext context) {
    final DateTime firstDayOfMonth = DateTime(
      calendarMonth.year,
      calendarMonth.month,
    );
    final DateTime lastDayOfMonth = DateTime(
      calendarMonth.year,
      calendarMonth.month + 1,
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
                onPressed: () => onMonthChanged(
                  DateTime(calendarMonth.year, calendarMonth.month - 1),
                ),
              ),
              Expanded(
                child: Text(
                  '${_getMonthName(calendarMonth.month)} ${calendarMonth.year}',
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
                onPressed: () => onMonthChanged(
                  DateTime(calendarMonth.year, calendarMonth.month + 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: <Widget>[
              Expanded(child: CalendarDayHeader('Min')),
              Expanded(child: CalendarDayHeader('Sen')),
              Expanded(child: CalendarDayHeader('Sel')),
              Expanded(child: CalendarDayHeader('Rab')),
              Expanded(child: CalendarDayHeader('Kam')),
              Expanded(child: CalendarDayHeader('Jum')),
              Expanded(child: CalendarDayHeader('Sab')),
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
              final bool inCurrentMonth = date.month == calendarMonth.month;
              final bool isSelected = _isSameDay(date, selectedDate);
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
                onTap: () => onSelectDate(date),
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
