import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';

class AuthTextAction extends StatelessWidget {
  const AuthTextAction({
    required this.label,
    required this.onPressed,
    super.key,
    this.alignment = AlignmentDirectional.centerEnd,
  });

  final String label;
  final VoidCallback onPressed;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AmanahButton.text(
        text: label,
        onPressed: onPressed,
        size: AmanahButtonSize.small,
      ),
    );
  }
}
