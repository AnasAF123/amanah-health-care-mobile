import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';

enum AuthProviderType { google, email }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.provider,
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final AuthProviderType provider;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color backgroundColor = provider == AuthProviderType.google
        ? (dark
              ? theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.50,
                )
              : const Color(0xFFF1F5F9))
        : (provider == AuthProviderType.email
              ? theme.colorScheme.secondary.withValues(alpha: 0.72)
              : theme.colorScheme.surface);
    final Color foregroundColor = theme.colorScheme.onSurface;

    return AmanahButton(
      text: label,
      onPressed: onPressed,
      variant: AmanahButtonVariant.ghost,
      size: AmanahButtonSize.large,
      leadingIcon: _ProviderIcon(provider: provider, color: foregroundColor),
      isLoading: loading,
      isDisabled: onPressed == null && !loading,
      isFullWidth: true,
      customBackgroundColor: backgroundColor,
      customForegroundColor: foregroundColor,
      boxShadow: const <BoxShadow>[],
      semanticsLabel: label,
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.provider, required this.color});

  final AuthProviderType provider;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (provider) {
      AuthProviderType.email => Icon(
        Icons.mail_outline_rounded,
        size: 21,
        color: color,
      ),
      AuthProviderType.google => SvgPicture.asset(
        'assets/amanah/auth/google_logo.svg',
        width: 20,
        height: 20,
      ),
    };
  }
}
