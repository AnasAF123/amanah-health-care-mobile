import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.assetPath, super.key});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
    );
  }
}

class AuthBackgroundScrim extends StatelessWidget {
  const AuthBackgroundScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = AmanahElevation.sheet(dark: dark).color;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                baseColor.withValues(alpha: dark ? 0.10 : 0.03),
                Colors.transparent,
                baseColor.withValues(alpha: 0.14),
                baseColor.withValues(alpha: 0.36),
                baseColor.withValues(alpha: 0.78),
              ],
              stops: const <double>[0, 0.36, 0.56, 0.76, 1],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.90,
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    baseColor.withValues(alpha: 0.08),
                    baseColor.withValues(alpha: 0.28),
                    baseColor.withValues(alpha: 0.54),
                  ],
                  stops: const <double>[0, 0.30, 0.66, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthClosedActions extends StatelessWidget {
  const AuthClosedActions({
    required this.onSignIn,
    super.key,
    this.hasPendingOnboarding = false,
    this.onResumeOnboarding,
  });

  final VoidCallback onSignIn;
  final bool hasPendingOnboarding;
  final VoidCallback? onResumeOnboarding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Portal Medis & Staf Amanah',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: AmanahColorTokens.surfaceLight,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(
                    'Sistem informasi terintegrasi untuk dokter, bidan, dan staf operasional Klinik Amanah.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.84),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.42,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            if (hasPendingOnboarding) ...<Widget>[
              AmanahButton.hero(
                text: 'Lanjutkan Pengisian Data',
                onPressed: onResumeOnboarding,
                size: AmanahButtonSize.large,
                isFullWidth: true,
              ),
              const SizedBox(height: MEDIUM_SPACE),
              AmanahButton.ghost(
                text: 'Masuk dengan Akun Lain',
                onPressed: onSignIn,
                size: AmanahButtonSize.large,
                isFullWidth: true,
                customForegroundColor: AmanahColorTokens.surfaceLight,
              ),
            ] else ...<Widget>[
              AmanahButton.hero(
                text: 'Masuk Akun Staf / Dokter',
                onPressed: onSignIn,
                size: AmanahButtonSize.large,
                isFullWidth: true,
              ),
            ],
            const SizedBox(height: 24),
            Text.rich(
              const TextSpan(
                text: 'Dengan melanjutkan, Anda menyetujui ',
                children: <InlineSpan>[
                  TextSpan(
                    text: 'syarat penggunaan',
                    style: TextStyle(
                      color: AmanahColorTokens.surfaceLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' dan memahami '),
                  TextSpan(
                    text: 'kebijakan privasi',
                    style: TextStyle(
                      color: AmanahColorTokens.surfaceLight,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' Amanah Healthcare.'),
                ],
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.78),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
