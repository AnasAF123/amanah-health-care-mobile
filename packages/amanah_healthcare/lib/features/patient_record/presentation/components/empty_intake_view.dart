import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Clean presentation view rendered when an appointment has no intake submission yet (404/Empty).
class EmptyIntakeView extends StatelessWidget {
  const EmptyIntakeView({super.key, this.complaint, required this.isDark});

  final String? complaint;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral100,
            ),
            child: Icon(
              Icons.assignment_late_outlined,
              size: 32,
              color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Formulir Belum Diisi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pasien atau petugas pendaftaran belum mengisi formulir intake klinis (skrining awal) untuk kunjungan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
            ),
          ),
          if (complaint != null && complaint!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: isDark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brandPrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keluhan Awal: $complaint',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.neutral900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
