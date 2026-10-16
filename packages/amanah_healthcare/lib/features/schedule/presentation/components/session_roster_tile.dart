import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';

class SessionRosterTile extends StatelessWidget {
  const SessionRosterTile({
    required this.session,
    required this.isActive,
    required this.onChanged,
    super.key,
  });

  final DoctorRosterSession session;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isActive
        ? (dark
            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.12)
            : AmanahColorTokens.brand.withValues(alpha: 0.08))
        : (dark
            ? AmanahColorTokens.surfaceSecondaryDark.withValues(alpha: 0.35)
            : AmanahColorTokens.neutral100.withValues(alpha: 0.5));

    final Color borderColor = isActive
        ? (dark
            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.4)
            : AmanahColorTokens.brand.withValues(alpha: 0.3))
        : (dark
            ? AmanahColorTokens.neutral700.withValues(alpha: 0.3)
            : AmanahColorTokens.neutral200);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  session.sessionLabel,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.surfaceLight
                        : AmanahColorTokens.neutral900,
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  session.timeRange,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            activeThumbColor: dark
                ? AmanahColorTokens.tabActiveDark
                : AmanahColorTokens.brand,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
