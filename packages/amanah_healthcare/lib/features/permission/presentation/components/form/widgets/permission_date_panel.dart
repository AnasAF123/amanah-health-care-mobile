import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Horizontal airline/booking-style date selection panel.
class PermissionDatePanel extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  final bool hasError;

  const PermissionDatePanel({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;
    final Color borderColor = hasError
        ? AmanahColorTokens.danger
        : (dark
            ? AmanahPermissionTokens.cardBorderDark
            : AmanahPermissionTokens.cardBorderLight);

    final Color panelBg = dark
        ? AmanahColorTokens.surfaceDark
        : AmanahColorTokens.surfaceLight;

    final String dayName = formatLocalizedDate(date, style: 'day_name');
    final String formattedDate =
        formatLocalizedDate(date, style: 'human_short');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: hasError ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                    letterSpacing: 0.3,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AmanahColorTokens.brand,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              dayName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AmanahColorTokens.brand,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
