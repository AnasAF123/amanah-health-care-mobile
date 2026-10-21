import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_entry_tile.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollBreakdownSection extends StatelessWidget {
  const PayrollBreakdownSection({required this.summary, super.key});

  final StaffPayrollSummary summary;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<PayrollEntry> entries = summary.entries;

    // Direct canonical monthLabel from upstream backend SSOT (e.g. "Oktober 2026")
    final String monthLabel = summary.monthLabel ?? summary.periodName ?? 'Bulan ini';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // --- MONTH SUB-HEADER (MATCHING WIREFRAME) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                ),
              ),
              Text(
                PayrollFormatters.currency(summary.netPayroll),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (entries.isEmpty)
          _EmptySubSection(message: 'Belum ada transaksi penggajian pada periode ini.', dark: dark)
        else
          ...entries.map((PayrollEntry entry) => PayrollEntryTile(entry: entry)),
      ],
    );
  }
}

class _EmptySubSection extends StatelessWidget {
  const _EmptySubSection({required this.message, required this.dark});

  final String message;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.neutral800.withValues(alpha: 0.3)
            : AmanahColorTokens.neutral100.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
          ),
        ),
      ),
    );
  }
}
