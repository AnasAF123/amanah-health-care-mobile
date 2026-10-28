import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';

/// Presentation widget rendering a dynamic clinical session/shift card option.
class DynamicSessionTile extends StatelessWidget {
  const DynamicSessionTile({required this.shift, required this.isSelected, this.onTap, super.key});

  final RescheduleShiftOption shift;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final bool isEnabled = shift.isAvailable && onTap != null;

    final Color bgColor = !isEnabled
        ? (dark
              ? AmanahColorTokens.surfaceSecondaryDark.withValues(alpha: 0.4)
              : AmanahColorTokens.neutral100)
        : (isSelected
              ? (dark ? AmanahColorTokens.brandNavyDark : AmanahColorTokens.brandSurface)
              : (dark ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.neutral50));

    final Color borderColor = isSelected
        ? AmanahColorTokens.brandPrimary
        : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 16,
                  color: !isEnabled
                      ? subtextColor.withValues(alpha: 0.5)
                      : (isSelected ? AmanahColorTokens.brandPrimary : subtextColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shift.sessionLabel.isNotEmpty ? shift.sessionLabel : shift.shift,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: !isEnabled ? subtextColor : textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Text(
                '${shift.startTime} - ${shift.endTime}',
                style: TextStyle(
                  fontSize: 11,
                  color: !isEnabled ? subtextColor.withValues(alpha: 0.7) : subtextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
