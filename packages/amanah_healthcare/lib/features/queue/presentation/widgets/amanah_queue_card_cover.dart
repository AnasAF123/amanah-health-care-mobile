import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahQueueCardCover extends StatelessWidget {
  const AmanahQueueCardCover({
    required this.card,
    this.width,
    this.height,
    super.key,
  });

  final AmanahQueueCardData card;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double cardW = width ?? 212.0;
    final double cardH = height ?? 335.0;
    final double logoSize = cardW * 0.46;

    return RepaintBoundary(
      child: Container(
        width: cardW,
        height: cardH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const <Color>[
                    AmanahColorTokens.surfaceElevatedDark,
                    AmanahColorTokens.neutral900,
                    AmanahColorTokens.canvasDark,
                  ]
                : const <Color>[
                    AmanahColorTokens.surfaceLight,
                    AmanahColorTokens.canvasLight,
                    AmanahColorTokens.brandSurface,
                  ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isDark
                  ? AmanahColorTokens.pureBlack.withValues(alpha: 0.65)
                  : AmanahColorTokens.navy.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 14),
              spreadRadius: isDark ? -2 : -6,
            ),
          ],
          border: Border.all(
            color: isDark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.14)
                : AmanahColorTokens.surfaceLight,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isDark
                          ? <Color>[
                              AmanahColorTokens.auroraCyanDark
                                  .withValues(alpha: 0.35),
                              AmanahColorTokens.neutral800
                                  .withValues(alpha: 0.15),
                              Colors.transparent,
                            ]
                          : <Color>[
                              AmanahColorTokens.brandMuted
                                  .withValues(alpha: 0.50),
                              AmanahColorTokens.brandSurface
                                  .withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                    ),
                  ),
                ),
              ),
              AmanahPixelTexture(
                isDark: isDark,
                opacity: isDark ? 0.45 : 0.38,
                maskType: AmanahPixelMaskType.fadeTop,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AmanahWatermarkLogo(
                    size: logoSize,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const <Color>[
                              AmanahColorTokens.cyanBright,
                              AmanahColorTokens.cyanAccent,
                              AmanahColorTokens.cyanLight,
                            ]
                          : const <Color>[
                              AmanahColorTokens.brandPrimary,
                              AmanahColorTokens.brandAccent,
                              AmanahColorTokens.brandLight,
                            ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.queueNumber,
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.cyanAccent
                          : AmanahColorTokens.brandPrimary,
                      fontSize: cardW > 250 ? 44 : 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: <Color>[
                        AmanahColorTokens.surfaceLight.withValues(
                          alpha: isDark ? 0.05 : 0.10,
                        ),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.45],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
