import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollHeroSalaryCard extends StatelessWidget {
  const PayrollHeroSalaryCard({required this.summary, super.key});

  final StaffPayrollSummary summary;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final double grossAmount = summary.grossEarnings > 0
        ? summary.grossEarnings
        : (summary.baseEarnings + summary.replacementAdditions);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const <Color>[
                  AmanahColorTokens.surfaceElevatedDark,
                  AmanahColorTokens.neutral900,
                  AmanahColorTokens.canvasDark,
                ]
              : const <Color>[
                  AmanahColorTokens.surfaceLight,
                  AmanahColorTokens.canvasLight,
                  AmanahColorTokens.brandSurface,
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.50)
                : AmanahColorTokens.navy.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: isDark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.12)
              : AmanahColorTokens.neutral200,
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: <Widget>[
            // Watermark signature logo
            Positioned(
              top: -24,
              right: -24,
              child: AmanahWatermarkLogo(
                size: 160,
                color: isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.brandPrimary,
                opacity: isDark ? 0.05 : 0.06,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Take Home Pay Section (Hero)
                  Text(
                    'Total gaji diterima',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    PayrollFormatters.currency(summary.netPayroll),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: isDark
                          ? AmanahColorTokens.surfaceLight
                          : AmanahColorTokens.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(
                    height: 1,
                    color: isDark
                        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                        : AmanahColorTokens.neutral200,
                  ),
                  const SizedBox(height: 14),

                  // 2. Metric Columns (Hick's Law Minimalist Anchors)
                  Builder(
                    builder: (BuildContext context) {
                      final bool hasDeductions = summary.leaveDeductions > 0;
                      final bool hasReplacement = summary.replacementAdditions > 0;

                      // Condition 1: If there are deductions, show breakdown (Hours | Gross | Deductions)
                      if (hasDeductions) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: _MetricCell(
                                label: 'Total jam pelayanan',
                                value: PayrollFormatters.hours(summary.baseHours),
                                color: isDark
                                    ? AmanahColorTokens.surfaceLight
                                    : AmanahColorTokens.neutral800,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: isDark
                                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                                  : AmanahColorTokens.neutral200,
                            ),
                            Expanded(
                              child: _MetricCell(
                                label: 'Penghasilan kotor',
                                value: PayrollFormatters.currency(grossAmount),
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: isDark
                                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                                  : AmanahColorTokens.neutral200,
                            ),
                            Expanded(
                              child: _MetricCell(
                                label: 'Total potongan',
                                value: '-${PayrollFormatters.currency(summary.leaveDeductions)}',
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        );
                      }

                      // Condition 2: If no deductions but has replacement shifts (Hours | Replacement)
                      if (hasReplacement) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: _MetricCell(
                                label: 'Total jam pelayanan',
                                value: PayrollFormatters.hours(summary.baseHours),
                                color: isDark
                                    ? AmanahColorTokens.surfaceLight
                                    : AmanahColorTokens.neutral800,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 32,
                              color: isDark
                                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                                  : AmanahColorTokens.neutral200,
                            ),
                            Expanded(
                              child: _MetricCell(
                                label: 'Upah pengganti',
                                value: PayrollFormatters.currency(summary.replacementAdditions),
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        );
                      }

                      // Condition 3: Clean standard state (zero deductions & zero replacement)
                      // Gross equals Net, so hide redundant Gross and 0 deductions
                      return Row(
                        children: <Widget>[
                          _MetricCell(
                            label: 'Total jam pelayanan',
                            value: PayrollFormatters.hours(summary.baseHours),
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral800,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.label,
    required this.value,
    required this.color,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final String label;
  final String value;
  final Color color;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}
