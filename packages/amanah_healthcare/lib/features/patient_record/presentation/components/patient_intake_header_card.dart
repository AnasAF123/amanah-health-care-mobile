import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Top minimalist header card displaying patient identity and medical record number.
class PatientIntakeHeaderCard extends StatelessWidget {
  const PatientIntakeHeaderCard({
    super.key,
    required this.patientName,
    required this.mrn,
    required this.age,
    required this.queueNumber,
    required this.flow,
    required this.isDark,
    this.statusText,
    this.statusVariant,
  });

  final String patientName;
  final String mrn;
  final String age;
  final String queueNumber;
  final String flow;
  final bool isDark;
  final String? statusText;
  final AmanahBadgeVariant? statusVariant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AmanahColorTokens.surfaceSecondaryDark
            : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AmanahColorTokens.neutral800
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark
                ? AmanahColorTokens.neutral800
                : AmanahColorTokens.neutral100,
            child: Text(
              patientName.isNotEmpty ? patientName.substring(0, 1).toUpperCase() : 'P',
              style: TextStyle(
                color: isDark
                    ? AmanahColorTokens.surfaceLight
                    : AmanahColorTokens.neutral900,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              patientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AmanahColorTokens.surfaceLight
                    : AmanahColorTokens.neutral900,
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (statusText != null && statusText!.isNotEmpty) ...<Widget>[
            const SizedBox(width: 8),
            AmanahStatusBadge(
              variant: statusVariant ?? AmanahBadgeVariant.live,
              text: statusText!,
            ),
          ],
        ],
      ),
    );
  }
}
