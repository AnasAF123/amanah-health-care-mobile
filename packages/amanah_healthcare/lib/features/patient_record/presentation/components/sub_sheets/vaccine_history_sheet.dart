import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/services/default_time_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';

/// Interactive Sub-Drawer Modal displaying complete pediatric vaccine schedule & status.
class VaccineHistorySheet extends StatelessWidget {
  VaccineHistorySheet({
    super.key,
    required this.entries,
    required this.isDark,
    TimeService? timeService,
  }) : timeService = timeService ?? DefaultTimeService();

  final List<VaccineEntryItem> entries;
  final bool isDark;
  final TimeService timeService;

  static void show(
    BuildContext context, {
    required List<VaccineEntryItem> entries,
    required bool isDark,
    TimeService? timeService,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          VaccineHistorySheet(entries: entries, isDark: isDark, timeService: timeService),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr.trim()).toLocal();
      return timeService.formatDate(dt, style: 'human_medium');
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int givenCount = entries
        .where((VaccineEntryItem e) => e.status.toUpperCase() == 'GIVEN' || e.status == 'Sudah')
        .length;

    return AmanahBottomSheetScaffold(
      title: 'Rekam Vaksinasi & Imunisasi Anak',
      fixedHeightFactor: 0.85,
      minHeight: 480,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: entries.isEmpty
          ? Center(
              child: Text(
                'Belum ada rekam jadwal vaksinasi anak yang tersimpan.',
                style: TextStyle(
                  color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                  fontSize: 13,
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Status: $givenCount dari ${entries.length} Vaksin Sudah Diberikan',
                      style: TextStyle(
                        color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AmanahColorTokens.surfaceSecondaryDark
                          : AmanahColorTokens.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: entries.asMap().entries.map((
                        MapEntry<int, VaccineEntryItem> entry,
                      ) {
                        final int idx = entry.key;
                        final VaccineEntryItem v = entry.value;
                        final bool isLast = idx == entries.length - 1;
                        final bool isGiven =
                            v.status.toUpperCase() == 'GIVEN' || v.status == 'Sudah';

                        return Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isGiven
                                          ? (isDark
                                                ? AmanahColorTokens.tabActiveDark.withValues(
                                                    alpha: 0.16,
                                                  )
                                                : AmanahColorTokens.brand.withValues(alpha: 0.08))
                                          : (isDark
                                                ? AmanahColorTokens.neutral800
                                                : AmanahColorTokens.neutral100),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isGiven ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                      size: 18,
                                      color: isGiven
                                          ? (isDark
                                                ? AmanahColorTokens.tabActiveDark
                                                : AmanahColorTokens.brandPrimary)
                                          : (isDark
                                                ? AmanahColorTokens.neutral400
                                                : AmanahColorTokens.neutral500),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Vaksin: ${v.vaccineCode}',
                                          style: TextStyle(
                                            color: isDark
                                                ? AmanahColorTokens.surfaceLight
                                                : AmanahColorTokens.neutral900,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          isGiven
                                              ? (v.givenDate != null
                                                    ? 'Diberikan: ${_formatDate(v.givenDate)}'
                                                    : 'Sudah Diberikan')
                                              : 'Belum Diberikan',
                                          style: TextStyle(
                                            color: isDark
                                                ? AmanahColorTokens.neutral400
                                                : AmanahColorTokens.neutral600,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (v.notes != null &&
                                            v.notes!.trim().isNotEmpty) ...<Widget>[
                                          const SizedBox(height: 2),
                                          Text(
                                            v.notes!,
                                            style: TextStyle(
                                              color: isDark
                                                  ? AmanahColorTokens.neutral500
                                                  : AmanahColorTokens.neutral500,
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isGiven
                                          ? (isDark
                                                ? AmanahColorTokens.tabActiveDark.withValues(
                                                    alpha: 0.16,
                                                  )
                                                : AmanahColorTokens.brand.withValues(alpha: 0.08))
                                          : (isDark
                                                ? AmanahColorTokens.neutral800
                                                : AmanahColorTokens.neutral100),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isGiven
                                            ? (isDark
                                                  ? AmanahColorTokens.tabActiveDark.withValues(
                                                      alpha: 0.32,
                                                    )
                                                  : AmanahColorTokens.brand.withValues(alpha: 0.20))
                                            : (isDark
                                                  ? AmanahColorTokens.neutral700
                                                  : AmanahColorTokens.neutral200),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      isGiven ? 'Sudah' : 'Belum',
                                      style: TextStyle(
                                        color: isGiven
                                            ? (isDark
                                                  ? AmanahColorTokens.tabActiveDark
                                                  : AmanahColorTokens.brandPrimary)
                                            : (isDark
                                                  ? AmanahColorTokens.neutral400
                                                  : AmanahColorTokens.neutral600),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Padding(
                                padding: const EdgeInsets.only(left: 48),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: isDark
                                      ? AmanahColorTokens.neutral800.withValues(alpha: 0.6)
                                      : AmanahColorTokens.neutral100,
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
