import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_calendar_picker.dart';

class RescheduleTargetDateSection extends StatelessWidget {
  const RescheduleTargetDateSection({
    required this.targetDate,
    required this.calendarMonth,
    required this.isCalendarOpen,
    required this.dark,
    required this.onToggleCalendar,
    required this.onMonthChanged,
    required this.onDateSelected,
    required this.formatDateDisplay,
    super.key,
  });

  final DateTime targetDate;
  final DateTime calendarMonth;
  final bool isCalendarOpen;
  final bool dark;
  final VoidCallback onToggleCalendar;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;
  final String Function(DateTime) formatDateDisplay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tanggal Target Praktik',
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral200
                : AmanahColorTokens.neutral700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggleCalendar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.12)
                        : AmanahColorTokens.brandLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatDateDisplay(targetDate),
                    style: TextStyle(
                      color: dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  isCalendarOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AmanahColorTokens.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isCalendarOpen) ...<Widget>[
          const SizedBox(height: 8),
          RescheduleCalendarPicker(
            calendarMonth: calendarMonth,
            targetDate: targetDate,
            onMonthChanged: onMonthChanged,
            onDateSelected: onDateSelected,
            dark: dark,
          ),
        ],
      ],
    );
  }
}
