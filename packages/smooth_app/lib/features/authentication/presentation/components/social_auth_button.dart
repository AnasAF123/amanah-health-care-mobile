import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
    final Color backgroundColor = provider == AuthProviderType.email
        ? theme.colorScheme.secondary.withValues(alpha: 0.72)
        : theme.colorScheme.surface;
    final Color foregroundColor = theme.colorScheme.onSurface;
    final Color borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.9,
    );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Semantics(
        button: true,
        label: label,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor.withValues(alpha: 0.72),
            disabledForegroundColor: foregroundColor.withValues(alpha: 0.72),
            shape: RoundedRectangleBorder(
              borderRadius: CIRCULAR_BORDER_RADIUS,
              side: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: loading
                ? SizedBox(
                    key: const ValueKey<String>('loading'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                : Row(
                    key: const ValueKey<String>('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _ProviderIcon(provider: provider, color: foregroundColor),
                      const SizedBox(width: MEDIUM_SPACE),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
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
