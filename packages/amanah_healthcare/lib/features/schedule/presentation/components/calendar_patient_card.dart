import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';

class CalendarPatientCard extends StatelessWidget {
  const CalendarPatientCard({
    required this.patient,
    this.onTap,
    super.key,
  });

  final SessionPatient patient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.surfaceSecondaryDark.withValues(alpha: 0.5)
            : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.neutral700.withValues(alpha: 0.35)
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Queue Number Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brand)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                patient.queueNumber,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.tabActiveDark
                      : AmanahColorTokens.brand,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Patient Name, RM, Complaint
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    patient.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dark
                          ? AmanahColorTokens.surfaceLight
                          : AmanahColorTokens.neutral900,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No. RM: ${patient.medicalRecordNumber} • ${patient.age}',
                    style: TextStyle(
                      color: dark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral500,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (patient.complaint != null &&
                      patient.complaint!.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      'Keluhan: ${patient.complaint}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral600,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status Badge
            AmanahStatusBadge(
              variant: patient.badgeVariant,
              text: patient.statusBadge,
            ),
          ],
        ),
      ),
    );
  }
}
