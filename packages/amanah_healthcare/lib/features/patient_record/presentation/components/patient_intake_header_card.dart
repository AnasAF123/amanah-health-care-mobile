import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Top header card displaying patient identity, medical record number, age, and flow tag.
class PatientIntakeHeaderCard extends StatelessWidget {
  const PatientIntakeHeaderCard({
    super.key,
    required this.patientName,
    required this.mrn,
    required this.age,
    required this.queueNumber,
    required this.flow,
    required this.isDark,
  });

  final String patientName;
  final String mrn;
  final String age;
  final String queueNumber;
  final String flow;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    Color tagBg = AmanahColorTokens.brandSurface;
    Color tagText = AmanahColorTokens.brandPrimary;
    String tagLabel = 'Poli Reguler';

    if (flow == 'pregnancy') {
      tagBg = Colors.pink.withValues(alpha: 0.12);
      tagText = Colors.pink.shade700;
      tagLabel = 'KIA / Kebidanan';
    } else if (flow == 'immunization') {
      tagBg = Colors.blue.withValues(alpha: 0.12);
      tagText = Colors.blue.shade700;
      tagLabel = 'Poli Anak & Vaksin';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AmanahColorTokens.surfaceSecondaryDark
            : AmanahColorTokens.neutral50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AmanahColorTokens.neutral800
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AmanahColorTokens.brandPrimary.withValues(alpha: 0.20)
                  : AmanahColorTokens.brandSurface,
              border: Border.all(
                color: AmanahColorTokens.brandPrimary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                patientName.isNotEmpty ? patientName.substring(0, 1) : 'P',
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.brandSoft
                      : AmanahColorTokens.brandPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? AmanahColorTokens.surfaceLight
                        : AmanahColorTokens.neutral900,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Text(
                      'RM: $mrn',
                      style: TextStyle(
                        color: isDark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (age != '-') ...<Widget>[
                      Text(
                        ' • $age',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tagLabel,
              style: TextStyle(
                color: tagText,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
