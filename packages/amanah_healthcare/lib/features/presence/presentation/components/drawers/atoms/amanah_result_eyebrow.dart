import 'package:flutter/material.dart';

/// Atom: Uppercase letter-spaced metadata eyebrow tag positioned above the main title.
class AmanahResultEyebrow extends StatelessWidget {
  const AmanahResultEyebrow({
    required this.text,
    required this.color,
    super.key,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: color,
      ),
    );
  }
}
