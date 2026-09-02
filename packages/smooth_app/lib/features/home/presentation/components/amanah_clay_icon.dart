import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_visual_role.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahClayIcon extends StatelessWidget {
  const AmanahClayIcon({
    required this.icon,
    super.key,
    this.tone = AmanahIconTone.brand,
    this.colorPrimary,
    this.colorLight,
    this.colorDark,
    this.size = 28,
  });

  final IconData icon;
  final AmanahIconTone tone;
  final Color? colorPrimary;
  final Color? colorLight;
  final Color? colorDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.28;
    final AmanahTone resolvedTone = AmanahThemeTokens.iconTone(tone);
    final Color primary = colorPrimary ?? resolvedTone.primary;
    final Color light = colorLight ?? resolvedTone.light;
    final Color dark = colorDark ?? resolvedTone.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[light, primary, dark],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: size * 0.52, color: Colors.white),
      ),
    );
  }
}
