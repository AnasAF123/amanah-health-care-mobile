import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/contracts/time_service.dart';
import 'package:amanah_healthcare/core/time/services/default_time_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Interactive Sub-Drawer Modal displaying complete contraceptive (KB) history.
class ContraceptiveHistorySheet extends StatelessWidget {
  ContraceptiveHistorySheet({
    super.key,
    required this.histories,
    required this.isDark,
    TimeService? timeService,
  }) : timeService = timeService ?? DefaultTimeService();

  final List<ContraceptiveHistoryItem> histories;
  final bool isDark;
  final TimeService timeService;

  static void show(
    BuildContext context, {
    required List<ContraceptiveHistoryItem> histories,
    required bool isDark,
    TimeService? timeService,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          ContraceptiveHistorySheet(histories: histories, isDark: isDark, timeService: timeService),
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
    return AmanahBottomSheetScaffold(
      title: 'Riwayat Kontrasepsi (KB)',
      fixedHeightFactor: 0.80,
      minHeight: 440,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: histories.isEmpty
          ? Center(
              child: Text(
                'Tidak ada catatan riwayat kontrasepsi / KB.',
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
                      'Total Tercatat: ${histories.length} Metode Kontrasepsi',
                      style: TextStyle(
                        color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...histories.asMap().entries.map((MapEntry<int, ContraceptiveHistoryItem> entry) {
                    final int idx = entry.key;
                    final ContraceptiveHistoryItem c = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AmanahColorTokens.surfaceSecondaryDark
                            : AmanahColorTokens.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AmanahColorTokens.neutral800
                              : AmanahColorTokens.neutral200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.4)
                                  : AmanahColorTokens.neutral100.withValues(alpha: 0.6),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.medication_outlined,
                                  size: 18,
                                  color: isDark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Metode KB Ke-${idx + 1}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AmanahColorTokens.surfaceLight
                                        : AmanahColorTokens.neutral900,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PatientDetailTile(
                            icon: Icons.health_and_safety_outlined,
                            label: 'Jenis / Metode Kontrasepsi',
                            value: c.contraceptiveType,
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'Tanggal Mulai Pemakaian',
                            value: _formatDate(c.startDate),
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.hourglass_top_rounded,
                            label: 'Durasi / Lama Pemakaian',
                            value: c.durationText ?? '-',
                            isDark: isDark,
                            showDivider: false,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
