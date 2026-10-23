import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahRevealedHeroCard extends StatelessWidget {
  const AmanahRevealedHeroCard({
    required this.card,
    required this.width,
    required this.height,
    required this.onDetailTap,
    super.key,
  });

  final AmanahQueueCardData card;
  final double width;
  final double height;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
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
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.70)
                : AmanahColorTokens.navy.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: isDark ? -4 : -12,
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
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -16,
              left: -24,
              child: AmanahWatermarkLogo(
                size: 200,
                color: isDark ? AmanahColorTokens.cyanAccent : AmanahColorTokens.brandPrimary,
                opacity: isDark ? 0.18 : 0.25,
              ),
            ),
            AmanahPixelTexture(
              isDark: isDark,
              opacity: isDark ? 0.30 : 0.22,
              maskType: AmanahPixelMaskType.bottomLeft,
            ),
            Positioned(
              top: 16,
              left: 20,
              right: width * 0.38,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    card.queueNumber,
                    maxLines: 1,
                    style: TextStyle(
                      color: isDark ? AmanahColorTokens.cyanAccent : AmanahColorTokens.brandPrimary,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 36,
              bottom: 74,
              width: width * 0.76,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AmanahColorTokens.pureBlack,
                      AmanahColorTokens.pureBlack,
                      Colors.transparent,
                    ],
                    stops: <double>[0.0, 0.68, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  card.doctorImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
            Positioned(
              bottom: 48,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: isDark
                            ? AmanahColorTokens.cyanAccent
                            : AmanahColorTokens.brandPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          card.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AmanahColorTokens.pureWhite
                                : AmanahColorTokens.neutral900,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.complaint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 20,
              child: Text(
                card.poly,
                style: TextStyle(
                  color: isDark ? AmanahColorTokens.cyanAccent : AmanahColorTokens.brandPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
