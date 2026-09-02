import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AmanahButton.primary(
      text: label,
      onPressed: onPressed,
      isLoading: loading,
      isDisabled: onPressed == null && !loading,
      isFullWidth: true,
      size: AmanahButtonSize.large,
      semanticsLabel: label,
    );
  }
}
