import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class RescheduleCalendarPicker extends StatelessWidget {
  const RescheduleCalendarPicker({
    required this.calendarMonth,
    required this.targetDate,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.dark,
    super.key,
  });

  final DateTime calendarMonth;
  final DateTime targetDate;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final bool dark;

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

    const List<String> monthNames = <String>[
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: () {
                  onMonthChanged(DateTime(
                    calendarMonth.year,
                    calendarMonth.month - 1,
                  ));
                },
              ),
              Text(
                '${monthNames[(calendarMonth.month - 1).clamp(0, 11)]} ${calendarMonth.year}',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral900,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: () {
                  onMonthChanged(DateTime(
                    calendarMonth.year,
                    calendarMonth.month + 1,
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gridDayCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 32,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (BuildContext context, int index) {
              final DateTime date = gridStart.add(Duration(days: index));
              final bool inCurrentMonth = date.month == calendarMonth.month;
              final bool isSelected = date.year == targetDate.year &&
                  date.month == targetDate.month &&
                  date.day == targetDate.day;

              if (!inCurrentMonth) {
                return const SizedBox.shrink();
              }

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onDateSelected(date),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected
                          ? (dark
                              ? AmanahColorTokens.canvasDark
                              : AmanahColorTokens.surfaceLight)
                          : (dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w600,
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
