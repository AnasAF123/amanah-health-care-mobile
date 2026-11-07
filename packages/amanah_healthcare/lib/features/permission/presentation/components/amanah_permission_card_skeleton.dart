import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_skeleton.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Contour skeleton matching the stacked ticket card motif of [AmanahPermissionCard].
class AmanahPermissionCardSkeleton extends StatelessWidget {
  const AmanahPermissionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: dark ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
              : AmanahColorTokens.neutral200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              AmanahSkeleton.box(width: 80, height: 24, borderRadius: 8),
              AmanahSkeleton.box(width: 60, height: 20, borderRadius: 6),
            ],
          ),
          SizedBox(height: 16),
          AmanahSkeleton.line(width: 180, height: 16, borderRadius: 4),
          SizedBox(height: 8),
          AmanahSkeleton.line(width: 120, height: 12, borderRadius: 4),
          Spacer(),
          AmanahSkeleton.line(width: double.infinity, height: 10, borderRadius: 3),
        ],
      ),
    );
  }
}
