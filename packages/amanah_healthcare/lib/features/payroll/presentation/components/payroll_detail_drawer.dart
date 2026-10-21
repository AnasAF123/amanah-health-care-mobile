import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class PayrollDetailDrawer extends StatelessWidget {
  const PayrollDetailDrawer({required this.entry, super.key});

  final PayrollEntry entry;

  static Future<void> show(BuildContext context, PayrollEntry entry) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => PayrollDetailDrawer(entry: entry),
    );
  }

  static String? _formatClockTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final DateTime? parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return '${formatLocalizedTime(parsed.toLocal())} WIB';
  }

  static void _showDescriptionModal(BuildContext context, String description) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: AmanahThemeTokens.elevatedSurface(ctx),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AmanahRadius.xl),
            side: BorderSide(color: AmanahThemeTokens.outline(ctx)),
          ),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline_rounded,
                color: AmanahThemeTokens.status(AmanahStatusTone.brand).primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Keterangan Transaksi',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AmanahThemeTokens.textPrimary(ctx),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AmanahThemeTokens.textSecondary(ctx),
              height: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Mengerti',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AmanahThemeTokens.status(AmanahStatusTone.brand).primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDeduction = entry.isDeduction;

    String dateFormatted = '-';
    if (entry.createdAt != null && entry.createdAt!.isNotEmpty) {
      final DateTime? parsed = parseIsoDateString(entry.createdAt!);
      if (parsed != null) {
        dateFormatted = formatLocalizedDate(parsed, style: 'human_medium');
      }
    }

    final String? formattedCheckIn = _formatClockTime(entry.checkInAt);
    final String? formattedCheckOut = _formatClockTime(entry.checkOutAt);
    final bool hasAttendanceNotes =
        entry.isEarlyDeparture || (entry.notes != null && entry.notes!.trim().isNotEmpty);

    final bool hasDescription = entry.description != null && entry.description!.trim().isNotEmpty;

    return AmanahBottomSheetScaffold(
      title: 'Rincian perhitungan upah',
      subtitle: dateFormatted,
      hugContent: true,
      maxHeightFactor: 0.88,
      showHeaderDivider: false,
      trailing: hasDescription
          ? Tooltip(
              message: entry.description!,
              triggerMode: TooltipTriggerMode.longPress,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AmanahThemeTokens.isDark(context)
                    ? AmanahColorTokens.neutral800
                    : AmanahColorTokens.neutral900,
                borderRadius: BorderRadius.circular(AmanahRadius.md),
              ),
              textStyle: const TextStyle(
                color: AmanahColorTokens.surfaceLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              child: IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 20),
                tooltip: 'Keterangan transaksi',
                color: AmanahThemeTokens.textSecondary(context),
                onPressed: () => _showDescriptionModal(context, entry.description!),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Clock In (only if real attendance data recorded)
          if (formattedCheckIn != null)
            _PayrollInfoRow(label: 'Jam Masuk', value: formattedCheckIn),

          // 2. Clock Out (only if real attendance data recorded)
          if (formattedCheckOut != null)
            _PayrollInfoRow(label: 'Jam Pulang', value: formattedCheckOut),

          // 3. Work Duration / Leave Duration
          _PayrollInfoRow(
            label: isDeduction ? 'Durasi Izin/Cuti' : 'Total Jam Kerja',
            value: PayrollFormatters.hours(entry.quantityHours),
          ),

          // 4. Hourly Rate / Replacement Rate
          _PayrollInfoRow(
            label: entry.entryType == 'replacement_addition'
                ? 'Tarif Dinas Pengganti'
                : 'Tarif per Jam',
            value: '${PayrollFormatters.currency(entry.hourlyRate)} / jam',
          ),

          // 5. Total Net Earnings / Total Deduction (Bottom row of wage calculation)
          _PayrollInfoRow(
            label: isDeduction ? 'Total Potongan' : 'Total Upah Bersih',
            value: '${isDeduction ? "-" : "+"}${PayrollFormatters.currency(entry.amount)}',
            isBold: true,
            valueColor: isDeduction
                ? AmanahThemeTokens.status(AmanahStatusTone.danger).primary
                : AmanahThemeTokens.status(AmanahStatusTone.brand).primary,
          ),

          // 6. Catatan Pulang & Early Departure
          if (hasAttendanceNotes) ...<Widget>[
            const SizedBox(height: AmanahSpacing.sm),
            const _PayrollDivider(),
            _PayrollTextSection(
              title: 'Catatan Pulang',
              body: entry.notes?.trim().isNotEmpty == true
                  ? entry.notes!
                  : 'Staf tercatat pulang lebih awal dari shift kerja yang ditentukan.',
              trailing: entry.isEarlyDeparture ? const _EarlyDepartureBadge() : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _EarlyDepartureBadge extends StatelessWidget {
  const _EarlyDepartureBadge();

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final AmanahTone tone = AmanahThemeTokens.status(AmanahStatusTone.warning);
    final Color background = dark ? tone.dark.withValues(alpha: 0.30) : tone.surface;
    final Color foreground = dark ? tone.light : tone.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmanahRadius.pill),
        border: Border.all(color: dark ? tone.primary.withValues(alpha: 0.32) : tone.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(color: tone.primary, shape: BoxShape.circle),
              child: const SizedBox(width: 6, height: 6),
            ),
            const SizedBox(width: 4),
            Text(
              'Pulang Lebih Awal',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollInfoRow extends StatelessWidget {
  const _PayrollInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AmanahThemeTokens.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: AmanahSpacing.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
                color: valueColor ?? AmanahThemeTokens.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PayrollTextSection extends StatelessWidget {
  const _PayrollTextSection({required this.title, required this.body, this.trailing});

  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmanahSpacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.04)
              : AmanahColorTokens.neutral100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AmanahThemeTokens.textSecondary(context),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AmanahThemeTokens.textPrimary(context),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayrollDivider extends StatelessWidget {
  const _PayrollDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: AmanahThemeTokens.outline(context));
  }
}
