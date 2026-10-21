import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

class PresenceHistorySummaryBar extends StatelessWidget {
  const PresenceHistorySummaryBar({
    required this.records,
    this.summary,
    required this.dark,
    required this.textColor,
    required this.subtextColor,
    super.key,
  });

  final List<AttendanceRecord> records;
  final AttendanceHistorySummary? summary;
  final bool dark;
  final Color textColor;
  final Color subtextColor;

  @override
  Widget build(BuildContext context) {
    int hadirCount = 0;
    int telatCount = 0;
    int missedCount = 0;
    int cutiCount = 0;

    if (summary != null && summary!.facets.isNotEmpty) {
      for (final AttendanceStatusFacet f in summary!.facets) {
        if (f.status == 'hadir') hadirCount = f.count;
        if (f.status == 'telat') telatCount = f.count;
        if (f.status == 'missed') missedCount = f.count;
        if (f.status == 'cuti') cutiCount = f.count;
      }
    } else {
      hadirCount = records.where((AttendanceRecord r) => r.status == AttendanceStatus.hadir).length;
      telatCount = records.where((AttendanceRecord r) => r.status == AttendanceStatus.telat).length;
      missedCount = records
          .where((AttendanceRecord r) => r.status == AttendanceStatus.missed)
          .length;
      cutiCount = records.where((AttendanceRecord r) => r.status == AttendanceStatus.cuti).length;
    }

    final int totalDays = summary?.totalDays ?? records.length;

    double validatedSum = 0;
    for (final AttendanceRecord r in records) {
      if (r.validatedDurationHours != null && r.validatedDurationHours! > 0) {
        validatedSum += r.validatedDurationHours!;
      }
    }

    final double totalHours = summary != null ? summary!.totalWorkHours : validatedSum;
    final String formattedHours = totalHours % 1 == 0
        ? '${totalHours.toInt()} hr'
        : '${totalHours.toStringAsFixed(1)} hr';

    final String periodLabel = summary?.periodLabel ?? 'Periode ini';

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
                  'Total jam kerja · $periodLabel',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subtextColor),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Text(
                      formattedHours,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($totalDays hari)',
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
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: summary != null && summary!.facets.isNotEmpty
                  ? summary!.facets
                        .map((AttendanceStatusFacet f) {
                          final Color col = switch (f.status) {
                            'hadir' => AmanahColorTokens.success,
                            'telat' => AmanahColorTokens.amberLight,
                            'missed' => AmanahColorTokens.danger,
                            'cuti' => AmanahColorTokens.violet,
                            _ => AmanahColorTokens.neutral400,
                          };
                          return _LegendIndicator(color: col, label: f.label);
                        })
                        .toList(growable: false)
                  : const <Widget>[
                      _LegendIndicator(color: AmanahColorTokens.success, label: 'Hadir'),
                      _LegendIndicator(color: AmanahColorTokens.amberLight, label: 'Telat'),
                      _LegendIndicator(color: AmanahColorTokens.danger, label: 'Missed'),
                      _LegendIndicator(color: AmanahColorTokens.violet, label: 'Cuti'),
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
