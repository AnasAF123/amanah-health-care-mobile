import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_draft_state.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Compact recap card showing the chosen permission type, dates, and scope.
class PermissionSummaryCard extends StatelessWidget {
  final PermissionDraftState draft;

  const PermissionSummaryCard({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;
    final Color cardBg = dark
        ? AmanahColorTokens.surfaceDark
        : AmanahColorTokens.surfaceLight;
    final Color borderColor = dark
        ? AmanahPermissionTokens.cardBorderDark
        : AmanahPermissionTokens.cardBorderLight;

    final String dateRangeStr =
        '${formatLocalizedDate(draft.dateRange.startDate, style: 'human_short')} — ${formatLocalizedDate(draft.dateRange.endDate, style: 'human_short')}';

    final String scopeDescription = draft.isFullDay
        ? '1 Hari Penuh'
        : 'Sesi Tertentu (${draft.selectedSessions.length} Sesi Terpilih)';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AmanahColorTokens.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  draft.type.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AmanahColorTokens.brand,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                      : AmanahColorTokens.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${draft.durationDays} Hari',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Icon(
                Icons.date_range_rounded,
                size: 14,
                color: subtextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateRangeStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: subtextColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  scopeDescription,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
