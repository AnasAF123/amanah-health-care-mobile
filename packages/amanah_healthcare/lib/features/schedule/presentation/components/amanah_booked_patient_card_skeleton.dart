import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_skeleton.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Contour skeleton placeholder matching the exact physical dimensions and shape of [AmanahBookedPatientCard].
/// Height: 355, BorderRadius: 32. Eliminates layout shift and prevents premature empty state flashes.
class AmanahBookedPatientCardSkeleton extends StatelessWidget {
  const AmanahBookedPatientCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 355,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AmanahThemeTokens.surface(context),
        border: Border.all(color: AmanahThemeTokens.outline(context), width: 1),
        boxShadow: <BoxShadow>[AmanahElevation.soft(dark: dark)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Top Row: Status badge on left, 3D Queue Medal silhouette on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                AmanahSkeleton.box(width: 88, height: 26, borderRadius: 8),
                AmanahSkeleton.box(width: 36, height: 36, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 18),

            // Time Slot silhouette
            const AmanahSkeleton.line(width: 110, height: 13, borderRadius: 4),
            const SizedBox(height: 12),

            // Patient Name silhouette
            const AmanahSkeleton.line(width: 200, height: 20, borderRadius: 6),
            const SizedBox(height: 8),

            // MRN & Age line
            const AmanahSkeleton.line(width: 140, height: 12, borderRadius: 4),
            const SizedBox(height: 16),

            // Complaint box silhouette
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: dark
                      ? AmanahColorTokens.surfaceSecondaryDark.withValues(alpha: 0.5)
                      : AmanahColorTokens.neutral100.withValues(alpha: 0.5),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AmanahSkeleton.line(width: 80, height: 10, borderRadius: 3),
                    SizedBox(height: 8),
                    AmanahSkeleton.line(width: double.infinity, height: 12, borderRadius: 4),
                    SizedBox(height: 6),
                    AmanahSkeleton.line(width: 160, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Bottom action row silhouette
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                AmanahSkeleton.box(width: 100, height: 36, borderRadius: 12),
                AmanahSkeleton.box(width: 36, height: 36, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
