import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Master Atomic Component for suspense loading skeleton placeholders.
/// Complies with Amanah clean design system and Android native performance.
class AmanahSkeleton extends StatefulWidget {
  const AmanahSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  const AmanahSkeleton.line({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius = 6,
  });

  const AmanahSkeleton.box({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  const AmanahSkeleton.card({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius = 16,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<AmanahSkeleton> createState() => _AmanahSkeletonState();
}

class _AmanahSkeletonState extends State<AmanahSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = dark
        ? AmanahColorTokens.surfaceSecondaryDark
        : AmanahColorTokens.neutral200;

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
