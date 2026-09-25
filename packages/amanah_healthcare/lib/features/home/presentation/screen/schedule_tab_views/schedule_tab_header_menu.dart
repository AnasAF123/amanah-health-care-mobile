import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class ScheduleTabHeaderMenu extends StatelessWidget {
  const ScheduleTabHeaderMenu({
    required this.dark,
    required this.daySetting,
    required this.onAddSchedule,
    required this.onToggleDayStatus,
    super.key,
  });

  final bool dark;
  final DayScheduleSetting daySetting;
  final VoidCallback onAddSchedule;
  final VoidCallback onToggleDayStatus;

  @override
  Widget build(BuildContext context) {
    final bool isDayClosed = daySetting.isDayClosed;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: dark
              ? AmanahColorTokens.surfaceDark
              : AmanahColorTokens.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.12)
                  : AmanahColorTokens.neutral200,
            ),
          ),
          elevation: 6,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Menu Opsi Jadwal',
        icon: Icon(
          Icons.more_vert_rounded,
          color: dark
              ? AmanahColorTokens.pureWhite
              : AmanahColorTokens.neutral800,
          size: 22,
        ),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onSelected: (String value) {
          if (value == 'add') {
            onAddSchedule();
          } else if (value == 'toggle_day') {
            onToggleDayStatus();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'add',
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18,
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tambah Jadwal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'toggle_day',
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                Icon(
                  isDayClosed
                      ? Icons.check_circle_outline_rounded
                      : Icons.block_flipped,
                  size: 18,
                  color: isDayClosed
                      ? AmanahColorTokens.success
                      : AmanahColorTokens.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDayClosed ? 'Buka Jadwal Hari Ini' : 'Tutup Jadwal Hari Ini',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDayClosed
                          ? AmanahColorTokens.success
                          : AmanahColorTokens.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
