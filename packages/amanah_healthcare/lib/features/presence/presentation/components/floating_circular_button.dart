import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class FloatingCircularButton extends StatelessWidget {
  const FloatingCircularButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.dark,
    this.size = 44,
    this.isActive = false,
  });

  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final bool dark;
  final double size;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Gradient? bgGradient = isActive
        ? (dark
              ? AmanahColorTokens.btnCrispBlueDarkGradient
              : AmanahColorTokens.btnCrispBlueGradient)
        : null;

    final Color? bgColor = isActive
        ? null
        : (dark
              ? AmanahColorTokens.neutral800.withValues(alpha: 0.75)
              : AmanahColorTokens.surfaceLight.withValues(alpha: 0.85));

    final Color iconColor = isActive
        ? AmanahColorTokens.surfaceLight
        : (dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral800);

    final Color borderColor = isActive
        ? (dark
              ? AmanahColorTokens.btnCrispBlueDarkBorder
              : AmanahColorTokens.btnCrispBlueBorder)
        : (dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.20)
              : AmanahColorTokens.surfaceLight.withValues(alpha: 0.80));

    final List<BoxShadow> shadows = <BoxShadow>[
      BoxShadow(
        color: AmanahColorTokens.pureBlack.withValues(alpha: dark ? 0.35 : 0.16),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              gradient: bgGradient,
              border: Border.all(
                color: borderColor,
                width: isActive ? 0.8 : 1.0,
              ),
              boxShadow: shadows,
            ),
            child: Center(
              child: Icon(icon, size: size * 0.48, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
