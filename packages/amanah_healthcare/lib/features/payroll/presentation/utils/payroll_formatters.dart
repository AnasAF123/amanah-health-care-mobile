import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

abstract final class PayrollFormatters {
  static String hours(num value) {
    if (value % 1 == 0) {
      return '${value.toInt()} jam';
    }
    return '${value.toStringAsFixed(1)} jam';
  }

  static String currency(num amount) {
    final bool isNegative = amount < 0;
    final int absVal = amount.abs().round();
    final String str = absVal.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${isNegative ? "- " : ""}Rp $buffer';
  }

  static String periodDateRange(String? startIso, String? endIso) {
    if (startIso == null || endIso == null || startIso.isEmpty || endIso.isEmpty) {
      return 'Periode Aktif';
    }
    final DateTime? start = parseIsoDateString(startIso);
    final DateTime? end = parseIsoDateString(endIso);
    if (start == null || end == null) {
      return '$startIso – $endIso';
    }
    final String startFormatted = formatLocalizedDate(start, style: 'human_short');
    final String endFormatted = formatLocalizedDate(end, style: 'human_short');
    return '$startFormatted – $endFormatted';
  }

  static String statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'calculated':
        return 'Terkalkulasi';
      case 'finalized':
        return 'Ditutup buku';
      case 'draft':
      default:
        return 'Draf';
    }
  }

  static AmanahBadgeVariant statusVariant(String status) {
    switch (status.toLowerCase()) {
      case 'finalized':
        return AmanahBadgeVariant.success;
      case 'calculated':
        return AmanahBadgeVariant.primary;
      case 'draft':
      default:
        return AmanahBadgeVariant.warning;
    }
  }

  static String entryTypeLabel(String entryType, {String? sourceType}) {
    switch (entryType) {
      case 'base_scheduled':
        return 'Upah hari ini';
      case 'leave_deduction':
        return 'Gaji di potong';
      case 'replacement_addition':
        return 'Upah pengganti';
      case 'overtime_addition':
        return 'Upah lembur';
      default:
        return 'Upah pelayanan';
    }
  }

  static IconData entryIcon(String entryType, {String? sourceType}) {
    switch (entryType) {
      case 'base_scheduled':
        return Icons.calendar_today_rounded;
      case 'leave_deduction':
        if (sourceType == 'attendance') {
          return Icons.timer_off_rounded;
        }
        return Icons.event_busy_rounded;
      case 'replacement_addition':
        return Icons.volunteer_activism_rounded;
      case 'overtime_addition':
        return Icons.more_time_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static Color entryColor(String entryType) {
    switch (entryType) {
      case 'base_scheduled':
        return AmanahColorTokens.sky;
      case 'leave_deduction':
        return AmanahColorTokens.danger;
      case 'replacement_addition':
        return AmanahColorTokens.success;
      case 'overtime_addition':
        return AmanahColorTokens.brand;
      default:
        return AmanahColorTokens.neutral600;
    }
  }
}
