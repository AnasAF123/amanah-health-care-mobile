import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

class PresenceHistorySummaryBar extends StatelessWidget {
  const PresenceHistorySummaryBar({
    required this.records,
    required this.dark,
    required this.textColor,
    required this.subtextColor,
    super.key,
  });

  final List<AttendanceRecord> records;
  final bool dark;
  final Color textColor;
  final Color subtextColor;

  @override
  Widget build(BuildContext context) {
    final int hadirCount = records
        .where((AttendanceRecord r) => r.status == AttendanceStatus.hadir)
        .length;
    final int telatCount = records
        .where((AttendanceRecord r) => r.status == AttendanceStatus.telat)
        .length;
    final int missedCount = records
        .where((AttendanceRecord r) => r.status == AttendanceStatus.missed)
        .length;
    final int cutiCount = records
        .where((AttendanceRecord r) => r.status == AttendanceStatus.cuti)
        .length;
    final int total = records.length;
    final int totalHours = (hadirCount + telatCount) * 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 10,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                : AmanahColorTokens.canvasLight,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: <Widget>[
              if (hadirCount > 0)
                Expanded(
                  flex: hadirCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.success,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              if (telatCount > 0)
                Expanded(
                  flex: telatCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.amberLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              if (missedCount > 0)
                Expanded(
                  flex: missedCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.danger,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              if (cutiCount > 0)
                Expanded(
                  flex: cutiCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.violet,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 10,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Total jam kerja · Periode ini',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      '$totalHours hr',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($total hari)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Wrap(
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                _LegendIndicator(
                  color: AmanahColorTokens.success,
                  label: 'Hadir',
                ),
                _LegendIndicator(
                  color: AmanahColorTokens.amberLight,
                  label: 'Telat',
                ),
                _LegendIndicator(
                  color: AmanahColorTokens.danger,
                  label: 'Missed',
                ),
                _LegendIndicator(
                  color: AmanahColorTokens.violet,
                  label: 'Cuti',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AmanahColorTokens.neutral500,
          ),
        ),
      ],
    );
  }
}
