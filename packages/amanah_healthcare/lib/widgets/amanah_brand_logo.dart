import 'package:flutter/material.dart';

/// Reusable Master Branding Component for Amanah Healthcare.
/// Displays the circular emblem alongside the official 'Amanah' Plus Jakarta Sans typography.
/// Fully theme-adaptive: foreground switches between #13195C in light mode and Colors.white in dark mode.
class AmanahBrandLogo extends StatelessWidget {
  const AmanahBrandLogo({
    super.key,
    this.emblemSize = 104,
    this.fontSize = 32,
    this.spacing = 8,
    this.isDark,
  });

  static const String emblemPath = 'assets/amanah/launch_emblem.png';

  final double emblemSize;
  final double fontSize;
  final double spacing;
  final bool? isDark;

  @override
  Widget build(BuildContext context) {
    final bool dark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final Color foreground = dark ? Colors.white : const Color(0xFF13195C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          emblemPath,
          width: emblemSize,
          height: emblemSize,
          fit: BoxFit.contain,
        ),
        SizedBox(height: spacing),
        Text(
          'Amanah',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: foreground,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}
