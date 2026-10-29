import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Presentation widget rendering the date selector input in the reschedule modal.
class RescheduleDatePickerField extends StatelessWidget {
  const RescheduleDatePickerField({
    required this.formattedDate,
    required this.onTap,
    super.key,
  });

  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color cardBg = dark
        ? AmanahColorTokens.surfaceSecondaryDark
        : AmanahColorTokens.neutral50;
    final Color borderColor = dark
        ? AmanahColorTokens.neutral700
        : AmanahColorTokens.neutral200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AmanahColorTokens.brandPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: subtextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
