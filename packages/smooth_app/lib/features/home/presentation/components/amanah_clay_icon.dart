import 'package:flutter/material.dart';

class AmanahClayIcon extends StatelessWidget {
  const AmanahClayIcon({
    required this.icon,
    required this.colorPrimary,
    required this.colorLight,
    required this.colorDark,
    super.key,
    this.size = 28,
  });

  final IconData icon;
  final Color colorPrimary;
  final Color colorLight;
  final Color colorDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double radius = size * 0.28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorLight,
            colorPrimary,
            colorDark,
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorDark.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.52,
          color: Colors.white,
        ),
      ),
    );
  }
}
