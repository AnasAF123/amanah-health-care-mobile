import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_detail_drawer.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollEntryTile extends StatelessWidget {
  const PayrollEntryTile({required this.entry, this.onTap, super.key});

  final PayrollEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final IconData icon = PayrollFormatters.entryIcon(
      entry.entryType,
      sourceType: entry.sourceType,
    );
    final Color toneColor = PayrollFormatters.entryColor(entry.entryType);
    final String typeLabel = PayrollFormatters.entryTypeLabel(
      entry.entryType,
      sourceType: entry.sourceType,
    );
    final bool isDeduction = entry.isDeduction;

    String dateSubtitle = '';
    if (entry.createdAt != null && entry.createdAt!.isNotEmpty) {
      final DateTime? parsed = parseIsoDateString(entry.createdAt!);
      if (parsed != null) {
        dateSubtitle = formatLocalizedDate(parsed, style: 'human_medium');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: dark ? AmanahThemeTokens.surface(context) : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ?? () => PayrollDetailDrawer.show(context, entry),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: toneColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: toneColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        dateSubtitle.isNotEmpty
                            ? dateSubtitle
                            : PayrollFormatters.hours(entry.quantityHours),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${isDeduction ? "-" : "+"}${PayrollFormatters.currency(entry.amount)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: toneColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
