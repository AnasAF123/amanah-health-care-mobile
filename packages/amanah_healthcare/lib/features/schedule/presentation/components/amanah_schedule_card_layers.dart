import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

AmanahTone amanahBadgeTone(AmanahBadgeVariant variant, [BuildContext? context]) {
  switch (variant) {
    case AmanahBadgeVariant.success:
      return AmanahThemeTokens.status(
        AmanahStatusTone.success,
        context: context,
      );
    case AmanahBadgeVariant.primary:
    case AmanahBadgeVariant.live:
      return AmanahThemeTokens.status(AmanahStatusTone.brand, context: context);
    case AmanahBadgeVariant.warning:
      return AmanahThemeTokens.status(
        AmanahStatusTone.warning,
        context: context,
      );
    case AmanahBadgeVariant.trend:
      return AmanahThemeTokens.status(
        AmanahStatusTone.violet,
        context: context,
      );
  }
}

class ProfileReadabilityMaskLayer extends StatelessWidget {
  const ProfileReadabilityMaskLayer({
    super.key,
    required this.dark,
    required this.height,
  });

  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.22, 0.42, 1.0],
              colors: <Color>[
                Colors.transparent,
                AmanahColorTokens.pureBlack.withValues(alpha: 0.45),
                AmanahColorTokens.pureBlack,
                AmanahColorTokens.pureBlack,
              ],
            ).createShader(bounds);
          },
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const <double>[0.0, 0.44, 1.0],
                    colors: dark
                        ? <Color>[
                            AmanahColorTokens.brandNavyDark.withValues(alpha: 0.0),
                            AmanahColorTokens.brandNavyDark.withValues(alpha: 0.72),
                            AmanahColorTokens.brandNavyDark.withValues(alpha: 0.97),
                          ]
                        : <Color>[
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.0),
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.86),
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.98),
                          ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AmbientCardGradientLayer extends StatelessWidget {
  const AmbientCardGradientLayer({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.25, 0.58, 0.88, 1.0],
              colors: dark
                  ? <Color>[
                      AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
                      AmanahColorTokens.pureBlack.withValues(alpha: 0.20),
                      AmanahColorTokens.brandNavyDark.withValues(alpha: 0.78),
                      AmanahColorTokens.brandNavyDark.withValues(alpha: 0.95),
                      AmanahColorTokens.brandNavyDark,
                    ]
                  : <Color>[
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.0),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.20),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.82),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.98),
                      AmanahColorTokens.pureWhite,
                    ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class PatientSpecRow extends StatelessWidget {
  const PatientSpecRow({
    super.key,
    required this.label,
    required this.value,
    required this.dark,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral100,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
