import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
    final Color foreground = dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.navy;

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
