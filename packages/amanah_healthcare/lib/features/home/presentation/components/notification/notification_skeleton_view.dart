import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_skeleton.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class NotificationSkeletonView extends StatelessWidget {
  const NotificationSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      itemCount: 6,
      separatorBuilder: (BuildContext context, int index) => Divider(
        height: 1,
        thickness: 1,
        color: dark
            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
            : AmanahColorTokens.neutral100,
      ),
      itemBuilder: (BuildContext context, int index) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Leading clay icon placeholder
              AmanahSkeleton.box(width: 32, height: 32, borderRadius: 10),
              SizedBox(width: 12),

              // Title and desc lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AmanahSkeleton.line(width: 140, height: 13, borderRadius: 4),
                    SizedBox(height: 6),
                    AmanahSkeleton.line(width: double.infinity, height: 11, borderRadius: 4),
                    SizedBox(height: 4),
                    AmanahSkeleton.line(width: 180, height: 11, borderRadius: 4),
                  ],
                ),
              ),
              SizedBox(width: 12),

              // Timestamp placeholder
              AmanahSkeleton.line(width: 32, height: 10, borderRadius: 3),
            ],
          ),
        );
      },
    );
  }
}
