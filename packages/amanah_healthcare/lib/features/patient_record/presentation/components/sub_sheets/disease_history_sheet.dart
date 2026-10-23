import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';

/// Interactive Sub-Drawer Modal displaying complete disease screening history (14 conditions).
class DiseaseHistorySheet extends StatelessWidget {
  const DiseaseHistorySheet({super.key, required this.diseases, required this.isDark});

  final List<MaternalDiseaseHistoryItem> diseases;
  final bool isDark;

  static void show(
    BuildContext context, {
    required List<MaternalDiseaseHistoryItem> diseases,
    required bool isDark,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => DiseaseHistorySheet(diseases: diseases, isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<MaternalDiseaseHistoryItem> positive = diseases
        .where((MaternalDiseaseHistoryItem d) => d.hasDisease)
        .toList();
    final List<MaternalDiseaseHistoryItem> negative = diseases
        .where((MaternalDiseaseHistoryItem d) => !d.hasDisease)
        .toList();

    return AmanahBottomSheetScaffold(
      title: 'Skrining Riwayat Penyakit & Operasi',
      fixedHeightFactor: 0.88,
      minHeight: 500,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Banner Ringkasan
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: positive.isNotEmpty
                    ? (isDark
                          ? AmanahColorTokens.warning.withValues(alpha: 0.15)
                          : AmanahColorTokens.warning.withValues(alpha: 0.08))
                    : (isDark
                          ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.16)
                          : AmanahColorTokens.brand.withValues(alpha: 0.08)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: positive.isNotEmpty
                      ? AmanahColorTokens.warning.withValues(alpha: 0.3)
                      : (isDark
                            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.32)
                            : AmanahColorTokens.brand.withValues(alpha: 0.20)),
                  width: 1,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    positive.isNotEmpty
                        ? Icons.info_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 22,
                    color: positive.isNotEmpty
                        ? AmanahColorTokens.warning
                        : (isDark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brandPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      positive.isNotEmpty
                          ? 'Ditemukan ${positive.length} kondisi riwayat medis/operasi yang tercatat saat skrining.'
                          : 'Tidak ditemukan riwayat penyakit kronis atau operasi khusus pada skrining.',
                      style: TextStyle(
                        color: isDark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.neutral900,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bagian 1: Kondisi Positif Terdiagnosis
            if (positive.isNotEmpty) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Kondisi Medis & Riwayat Terdiagnosis',
                  style: TextStyle(
                    color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ...positive.map((MaternalDiseaseHistoryItem d) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AmanahColorTokens.surfaceSecondaryDark
                        : AmanahColorTokens.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.warning.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_information_outlined,
                          size: 18,
                          color: AmanahColorTokens.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              d.diseaseName,
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
                              d.yearOrNotes != null
                                  ? 'Terdiagnosis / Catatan: ${d.yearOrNotes}'
                                  : 'Ada Riwayat',
                              style: TextStyle(
                                color: isDark
                                    ? AmanahColorTokens.neutral400
                                    : AmanahColorTokens.neutral600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Positif',
                          style: TextStyle(
                            color: AmanahColorTokens.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Bagian 2: Kondisi Negatif / Tidak Ada
            if (negative.isNotEmpty) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Kondisi Medis Tanpa Riwayat (${negative.length})',
                  style: TextStyle(
                    color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
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
                  children: negative.asMap().entries.map((
                    MapEntry<int, MaternalDiseaseHistoryItem> entry,
                  ) {
                    final int idx = entry.key;
                    final MaternalDiseaseHistoryItem d = entry.value;
                    final bool isLast = idx == negative.length - 1;

                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                                color: isDark
                                    ? AmanahColorTokens.neutral500
                                    : AmanahColorTokens.neutral400,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  d.diseaseName,
                                  style: TextStyle(
                                    color: isDark
                                        ? AmanahColorTokens.neutral300
                                        : AmanahColorTokens.neutral700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                'Tidak ada',
                                style: TextStyle(
                                  color: isDark
                                      ? AmanahColorTokens.neutral500
                                      : AmanahColorTokens.neutral400,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Padding(
                            padding: const EdgeInsets.only(left: 46),
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
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
