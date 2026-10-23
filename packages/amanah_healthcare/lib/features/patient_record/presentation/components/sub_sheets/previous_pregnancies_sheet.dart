import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/presentation/components/patient_detail_grouped_card.dart';

/// Interactive Sub-Drawer Modal displaying complete obstetric delivery history (100% exposed fields).
class PreviousPregnanciesSheet extends StatelessWidget {
  const PreviousPregnanciesSheet({super.key, required this.pregnancies, required this.isDark});

  final List<PreviousPregnancyItem> pregnancies;
  final bool isDark;

  static void show(
    BuildContext context, {
    required List<PreviousPregnancyItem> pregnancies,
    required bool isDark,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          PreviousPregnanciesSheet(pregnancies: pregnancies, isDark: isDark),
    );
  }

  String _formatWeight(int? grams) {
    if (grams == null || grams <= 0) return '-';
    final double kg = grams / 1000.0;
    return '$grams gram (${kg.toStringAsFixed(1)} kg)';
  }

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Riwayat Persalinan Sebelumnya',
      fixedHeightFactor: 0.85,
      minHeight: 480,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: pregnancies.isEmpty
          ? Center(
              child: Text(
                'Tidak ada catatan riwayat persalinan sebelumnya.',
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
                      'Total Tercatat: ${pregnancies.length} Anak',
                      style: TextStyle(
                        color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...pregnancies.map((PreviousPregnancyItem p) {
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
                          // Header Card
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
                                  Icons.child_friendly_rounded,
                                  size: 18,
                                  color: isDark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Anak Ke-${p.orderNumber}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AmanahColorTokens.surfaceLight
                                        : AmanahColorTokens.neutral900,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.16)
                                        : AmanahColorTokens.brand.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isDark
                                          ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.32)
                                          : AmanahColorTokens.brand.withValues(alpha: 0.20),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    p.birthYear != null ? 'Tahun ${p.birthYear}' : 'Tahun -',
                                    style: TextStyle(
                                      color: isDark
                                          ? AmanahColorTokens.tabActiveDark
                                          : AmanahColorTokens.brandPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Detail Fields (100% Exposed)
                          PatientDetailTile(
                            icon: Icons.wc_outlined,
                            label: 'Jenis Kelamin Anak',
                            value: p.childSex ?? '-',
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Berat Badan Lahir',
                            value: _formatWeight(p.birthWeightGrams),
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.local_hospital_outlined,
                            label: 'Cara / Metode Persalinan',
                            value: p.deliveryMethod ?? 'Normal',
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.medical_services_outlined,
                            label: 'Tenaga Penolong Persalinan',
                            value: p.birthAttendant ?? '-',
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.location_on_outlined,
                            label: 'Tempat / Fasilitas Persalinan',
                            value: p.deliveryPlace ?? '-',
                            isDark: isDark,
                          ),
                          PatientDetailTile(
                            icon: Icons.warning_amber_rounded,
                            label: 'Komplikasi / Catatan Khusus',
                            value: (p.complications != null && p.complications!.trim().isNotEmpty)
                                ? p.complications!
                                : 'Tidak ada komplikasi',
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
