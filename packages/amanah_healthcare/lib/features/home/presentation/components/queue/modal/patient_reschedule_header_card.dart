import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Presentation card displaying patient and doctor queue metadata in the reschedule modal.
class PatientRescheduleHeaderCard extends StatelessWidget {
  const PatientRescheduleHeaderCard({
    required this.queueNumber,
    required this.patientName,
    required this.doctorAndServiceText,
    super.key,
  });

  final String queueNumber;
  final String patientName;
  final String doctorAndServiceText;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color cardBg = dark
        ? AmanahColorTokens.surfaceSecondaryDark
        : AmanahColorTokens.neutral50;
    final Color borderColor = dark
        ? AmanahColorTokens.neutral700
        : AmanahColorTokens.neutral200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: AmanahColorTokens.brandPrimary,
            radius: 20,
            child: Text(
              queueNumber,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctorAndServiceText,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
