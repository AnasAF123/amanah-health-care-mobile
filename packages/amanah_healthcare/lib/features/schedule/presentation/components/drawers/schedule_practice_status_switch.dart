import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_confirm_close_practice_drawer.dart';

/// Horizontal status switch for practice status (Buka / Tutup) in Edit Schedule form.
class SchedulePracticeStatusSwitch extends StatelessWidget {
  const SchedulePracticeStatusSwitch({
    required this.status,
    required this.selectedDate,
    required this.dark,
    required this.onChanged,
    super.key,
  });

  final String status;
  final DateTime selectedDate;
  final bool dark;
  final ValueChanged<String> onChanged;

  bool get isOpen =>
      status != ScheduleFormConstants.statusTutup &&
      status != ScheduleFormConstants.statusCuti;

  Future<void> _handleToggle(BuildContext context) async {
    if (isOpen) {
      // Currently open -> user wants to close -> prompt confirmation drawer
      final bool confirmed = await AmanahConfirmClosePracticeDrawer.show(
        context,
        date: selectedDate,
      );
      if (confirmed) {
        onChanged(ScheduleFormConstants.statusTutup);
      }
    } else {
      // Currently closed -> user wants to reopen -> immediately open
      onChanged(ScheduleFormConstants.statusBuka);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool open = isOpen;
    final Color activeColor =
        dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.success;
    final Color inactiveColor = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.18)
        : AmanahColorTokens.neutral300;
    final Color dotColor =
        open ? AmanahColorTokens.emeraldLight : AmanahColorTokens.roseLight;
    final Color textColor = open
        ? (dark ? AmanahColorTokens.emeraldLight : AmanahColorTokens.success)
        : (dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _handleToggle(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Indicator Dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            // Text Label
            Text(
              open
                  ? ScheduleFormConstants.statusBuka
                  : ScheduleFormConstants.statusTutup,
              style: TextStyle(
                color: textColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 7),
            // Switch Slider
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 36,
              height: 20,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: open ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: open ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.pureWhite,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color:
                            AmanahColorTokens.pureBlack.withValues(alpha: 0.20),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
