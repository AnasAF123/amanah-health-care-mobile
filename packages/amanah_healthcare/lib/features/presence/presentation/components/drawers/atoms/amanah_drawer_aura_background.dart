import 'package:flutter/material.dart';
 import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

/// Atom: Top ambient radial gradient aura behind the badge stage.
class AmanahDrawerAuraBackground extends StatelessWidget {
  const AmanahDrawerAuraBackground({
    required this.badgeTheme,
    required this.dark,
    super.key,
    this.height = 215.0,
  });

  final BadgeStageTheme badgeTheme;
  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color centerColor = dark ? const Color(0xFF16181D) : Colors.white;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, 0.70),
            radius: 1.05,
            colors: <Color>[
              centerColor,
              badgeTheme.auraMid,
              badgeTheme.auraEdge,
            ],
            stops: const <double>[0.22, 0.68, 1.0],
          ),
        ),
      ),
    );
  }
}
