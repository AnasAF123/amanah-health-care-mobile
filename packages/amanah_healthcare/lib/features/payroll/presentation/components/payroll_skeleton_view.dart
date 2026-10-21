import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_skeleton.dart';

class PayrollSkeletonView extends StatelessWidget {
  const PayrollSkeletonView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Period Selector Skeleton
          AmanahSkeleton.card(height: 62, borderRadius: 18),
          SizedBox(height: 16),

          // Hero Salary Card Skeleton
          AmanahSkeleton.card(height: 196, borderRadius: 24),
          SizedBox(height: 20),

          // Section Header Skeleton
          AmanahSkeleton.line(width: 180, height: 16, borderRadius: 4),
          SizedBox(height: 12),

          // Itemized entries skeleton
          AmanahSkeleton.card(height: 80, borderRadius: 16),
          SizedBox(height: 10),
          AmanahSkeleton.card(height: 80, borderRadius: 16),
          SizedBox(height: 10),
          AmanahSkeleton.card(height: 80, borderRadius: 16),
        ],
      ),
    );
  }
}
