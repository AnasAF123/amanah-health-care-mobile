import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollPeriodSelectorCard extends StatelessWidget {
  const PayrollPeriodSelectorCard({
    required this.periods,
    required this.selectedPeriod,
    required this.onPeriodSelected,
    super.key,
  });

  final List<PayrollPeriod> periods;
  final PayrollPeriod? selectedPeriod;
  final ValueChanged<PayrollPeriod> onPeriodSelected;

  Future<void> _openPicker(BuildContext context) async {
    if (periods.isEmpty) return;

    final PayrollPeriod? picked = await showModalBottomSheet<PayrollPeriod>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final bool dark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: 24 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              Text(
                'Pilih periode penggajian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: periods.length,
                  separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext _, int index) {
                    final PayrollPeriod period = periods[index];
                    final bool isCurrent = selectedPeriod?.id == period.id;

                    return InkWell(
                      onTap: () => Navigator.of(ctx).pop(period),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AmanahColorTokens.sky.withValues(alpha: 0.10)
                              : (dark
                                    ? AmanahColorTokens.neutral800.withValues(alpha: 0.35)
                                    : AmanahColorTokens.neutral100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent ? AmanahColorTokens.sky : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    period.periodName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: isCurrent
                                          ? AmanahColorTokens.sky
                                          : (dark
                                                ? AmanahColorTokens.surfaceLight
                                                : AmanahColorTokens.neutral900),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    PayrollFormatters.periodDateRange(
                                      period.periodStart,
                                      period.periodEnd,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: dark
                                          ? AmanahColorTokens.neutral400
                                          : AmanahColorTokens.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AmanahStatusBadge(
                              text: PayrollFormatters.statusLabel(period.status),
                              variant: PayrollFormatters.statusVariant(period.status),
                              fontSize: 10,
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
      },
    );

    if (picked != null) {
      onPeriodSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: dark ? AmanahThemeTokens.surface(context) : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.sky.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AmanahColorTokens.sky,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        selectedPeriod?.periodName ?? 'Periode penggajian',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        selectedPeriod != null
                            ? PayrollFormatters.periodDateRange(
                                selectedPeriod!.periodStart,
                                selectedPeriod!.periodEnd,
                              )
                            : 'Memuat data periode...',
                        style: TextStyle(
                          fontSize: 11,
                          color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedPeriod != null)
                  AmanahStatusBadge(
                    text: PayrollFormatters.statusLabel(selectedPeriod!.status),
                    variant: PayrollFormatters.statusVariant(selectedPeriod!.status),
                    fontSize: 9.5,
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
