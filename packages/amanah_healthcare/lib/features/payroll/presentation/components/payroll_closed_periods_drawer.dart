import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollClosedPeriodsDrawer extends StatelessWidget {
  const PayrollClosedPeriodsDrawer({
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    super.key,
  });

  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final ValueChanged<PayrollPeriod> onPeriodSelected;

  static Future<void> show({
    required BuildContext context,
    required List<PayrollPeriod> periods,
    required PayrollPeriod? selectedPeriod,
    required ValueChanged<PayrollPeriod> onPeriodSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => PayrollClosedPeriodsDrawer(
        periods: periods,
        selectedPeriod: selectedPeriod,
        onPeriodSelected: onPeriodSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<PayrollPeriod> closedPeriods = periods
        .where((PayrollPeriod p) => p.status.toLowerCase() == 'finalized')
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: dark ? AmanahThemeTokens.surface(context) : AmanahColorTokens.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Histori penggajian',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daftar bulan yang telah tutup buku',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick action: Kembali ke Bulan Berjalan
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).pop();
              // Reset selection to default active month
              final PayrollPeriod activePeriod = periods.firstWhere(
                (PayrollPeriod p) => p.status.toLowerCase() != 'finalized',
                orElse: () => periods.first,
              );
              onPeriodSelected(activePeriod);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AmanahColorTokens.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AmanahColorTokens.brandPrimary.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.brandPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.today_rounded,
                      color: AmanahColorTokens.brandPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Bulan berjalan (Sedang aktif)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AmanahColorTokens.brandPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kalkulasi berjalan real-time dinas',
                          style: TextStyle(
                            fontSize: 11,
                            color: dark
                                ? AmanahColorTokens.neutral400
                                : AmanahColorTokens.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AmanahColorTokens.brandPrimary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Closed periods list
          Text(
            'Arsip bulan tutup buku',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
            ),
          ),
          const SizedBox(height: 8),

          if (closedPeriods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada bulan yang ditutup buku.',
                  style: TextStyle(
                    fontSize: 12,
                    color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: closedPeriods.length,
                separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 8),
                itemBuilder: (BuildContext ctx, int index) {
                  final PayrollPeriod period = closedPeriods[index];
                  final bool isSelected = selectedPeriod?.id == period.id;

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.of(context).pop();
                      onPeriodSelected(period);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AmanahColorTokens.brandPrimary.withValues(alpha: 0.1)
                            : (dark
                                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.3)
                                  : AmanahColorTokens.neutral100.withValues(alpha: 0.6)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AmanahColorTokens.brandPrimary
                              : (dark
                                    ? AmanahThemeTokens.outline(context)
                                    : AmanahColorTokens.neutral200),
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.archive_outlined,
                            size: 20,
                            color: AmanahColorTokens.neutral500,
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
                            text: 'Tutup buku',
                            variant: AmanahBadgeVariant.success,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
