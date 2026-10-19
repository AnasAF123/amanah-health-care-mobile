import 'package:flutter/material.dart';

/// Atom: Centered, subtle horizontal divider separating the title and description.
class AmanahResultDivider extends StatelessWidget {
  const AmanahResultDivider({
    required this.color,
    super.key,
    this.width = 124.0,
    this.height = 1.0,
    this.verticalMargin = 14.0,
  });

  final Color color;
  final double width;
  final double height;
  final double verticalMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.symmetric(vertical: verticalMargin),
      color: color,
    );
  }
}
