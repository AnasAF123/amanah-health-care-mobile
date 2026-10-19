import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/widgets/permission_date_panel.dart';

/// Stage 2: Select date range via horizontal side-by-side panels.
class PermissionDateStage extends StatelessWidget {
  final CalendarDateRange dateRange;
  final ValueChanged<CalendarDateRange> onDateRangeChanged;
  final VoidCallback onContinue;

  const PermissionDateStage({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.onContinue,
  });

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateRange.startDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Mulai Izin',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      final DateTime normalized = normalizeToCalendarDate(picked);
      final DateTime newEnd = dateRange.endDate.isBefore(normalized)
          ? normalized
          : dateRange.endDate;
      onDateRangeChanged(CalendarDateRange(start: normalized, end: newEnd));
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final DateTime initial = dateRange.endDate.isBefore(dateRange.startDate)
        ? dateRange.startDate
        : dateRange.endDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: dateRange.startDate,
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Selesai Izin',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      final DateTime normalized = normalizeToCalendarDate(picked);
      onDateRangeChanged(
        CalendarDateRange(start: dateRange.startDate, end: normalized),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pilih tanggal mulai dan tanggal selesai pengajuan izin.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),

        // Horizontal Side-by-Side Date Panels
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: PermissionDatePanel(
                label: 'Tanggal Mulai',
                date: dateRange.startDate,
                onTap: () => _pickStartDate(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AmanahColorTokens.brand,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.brand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${dateRange.durationDays} Hari',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AmanahColorTokens.brand,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PermissionDatePanel(
                label: 'Tanggal Selesai',
                date: dateRange.endDate,
                onTap: () => _pickEndDate(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Continue Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AmanahColorTokens.brand,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Lanjutkan ke Lingkup',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
