import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/export/presentation/components/amanah_export_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollExportPeriodDrawer extends StatelessWidget {
  const PayrollExportPeriodDrawer({
    required this.periods,
    super.key,
  });

  final List<PayrollPeriod> periods;

  static Future<void> show({
    required BuildContext context,
    required List<PayrollPeriod> periods,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => PayrollExportPeriodDrawer(periods: periods),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final List<PayrollPeriod> exportablePeriods = periods
        .where((PayrollPeriod p) {
          final String s = p.status.toLowerCase();
          return s == 'finalized' || s == 'calculated';
        })
        .toList(growable: false);

    return AmanahBottomSheetScaffold(
      title: 'Unduh Rekap Penggajian',
      subtitle: 'Pilih periode penggajian untuk mengekspor rekap resmi',
      hugContent: true,
      body: _buildList(context, dark, exportablePeriods),
    );
  }

  Widget _buildList(
    BuildContext context,
    bool dark,
    List<PayrollPeriod> exportablePeriods,
  ) {
    if (exportablePeriods.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Tidak ada periode yang tersedia untuk diekspor',
            style: TextStyle(
              fontSize: 12,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exportablePeriods.length,
      separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext ctx, int index) {
        final PayrollPeriod period = exportablePeriods[index];
        final bool isFinalized = period.status.toLowerCase() == 'finalized';

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).pop();
            AmanahExportSheet.show(
              context: context,
              exportType: 'payroll',
              sheetTitle: 'Unduh Rekap Penggajian',
              sheetSubtitle: period.periodName,
              parameters: <String, dynamic>{
                'periodId': period.id,
                'periodName': period.periodName,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.3)
                  : AmanahColorTokens.neutral100.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
                width: 0.8,
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 22,
                  color: AmanahColorTokens.brandPrimary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        period.periodName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        PayrollFormatters.periodDateRange(
                          period.periodStart,
                          period.periodEnd,
                        ),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: dark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                AmanahStatusBadge(
                  text: isFinalized ? 'Tutup buku' : 'Terkalkulasi',
                  variant: isFinalized ? AmanahBadgeVariant.success : AmanahBadgeVariant.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
