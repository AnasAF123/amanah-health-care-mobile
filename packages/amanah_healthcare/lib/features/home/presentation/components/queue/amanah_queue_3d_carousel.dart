import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahQueue3DCarousel extends StatelessWidget {
  const AmanahQueue3DCarousel({
    super.key,
    required this.cards,
    required this.currentIndex,
    required this.horizontalDrag,
    required this.verticalDrag,
    required this.spinOffset,
    required this.isActivating,
    required this.ejectionStage,
    required this.showSuccess,
    required this.onCardSelect,
  });

  final List<AmanahQueueCardData> cards;
  final int currentIndex;
  final double horizontalDrag;
  final double verticalDrag;
  final double spinOffset;
  final bool isActivating;
  final String ejectionStage;
  final bool showSuccess;
  final ValueChanged<int> onCardSelect;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double totalDragOffset = horizontalDrag - spinOffset;
    final double dragUnits = totalDragOffset / 230.0;
    final double baseTop = math.max(16.0, screen.height * 0.05);

    final List<Widget> cardWidgets = <Widget>[];

    // Target Frame
    cardWidgets.add(
      Positioned(
        left: (screen.width - 218) / 2,
        top: baseTop - 3,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: isActivating || showSuccess ? 0.0 : 1.0,
          child: Container(
            width: 218,
            height: 341,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AmanahColorTokens.brandLight.withValues(alpha: 0.75),
                width: 1.8,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AmanahColorTokens.brandLight.withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Aerodynamic Racing Chevrons
    cardWidgets.add(
      Positioned(
        left: 0,
        right: 0,
        top: baseTop + 348,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (isActivating || showSuccess || ejectionStage != 'idle')
                ? 0.0
                : (1.0 - (verticalDrag / 40.0)).clamp(0.0, 1.0),
            child: const AmanahRacingPulseChevrons(),
          ),
        ),
      ),
    );

    // 3D Cards with U-Railway Geometry
    for (int index = 0; index < cards.length; index++) {
      double distanceFromCenter = (index - currentIndex) + dragUnits;

      while (distanceFromCenter > cards.length / 2) {
        distanceFromCenter -= cards.length;
      }
      while (distanceFromCenter < -cards.length / 2) {
        distanceFromCenter += cards.length;
      }

      if (distanceFromCenter.abs() > 2.8) {
        continue;
      }

      final bool isCenter = index == currentIndex && totalDragOffset.abs() < 24;
      final double angleDeg = distanceFromCenter * 19.5;
      final double angleRad = angleDeg * math.pi / 180.0;

      final double x = 660.0 * math.sin(angleRad) * (screen.width / 420.0);
      double y = -660.0 * (1.0 - math.cos(angleRad)) * 0.8;
      final double rotateZ = -distanceFromCenter * 13.0 * math.pi / 180.0;
      final double rotateY = distanceFromCenter * 8.0 * math.pi / 180.0;
      final double scale =
          1.0 - math.min(0.06, distanceFromCenter.abs() * 0.035);
      double opacity =
          (1.0 - (distanceFromCenter.abs() - 0.85).clamp(0.0, 1.0) * 0.95)
              .clamp(0.0, 1.0);

      if (isCenter && verticalDrag > 0) {
        y += verticalDrag;
      }

      if (isActivating || showSuccess || ejectionStage == 'dock_appear') {
        if (index != currentIndex) {
          opacity = 0.0;
        } else {
          y = 650.0;
          opacity = showSuccess ? 0.0 : 1.0;
        }
      } else if (ejectionStage == 'rail_converge') {
        if (index == currentIndex) {
          y = 650.0;
          opacity = 0.0;
        } else {
          opacity = 1.0;
        }
      } else if (ejectionStage == 'atm_peek') {
        if (index == currentIndex) {
          y = 165.0;
          opacity = 1.0;
        }
      } else if (ejectionStage == 'full_eject') {
        if (index == currentIndex) {
          y = 0.0;
          opacity = 1.0;
        }
      }

      cardWidgets.add(
        Positioned(
          key: ValueKey<String>(cards[index].id),
          left: (screen.width - 212) / 2 + x,
          top: baseTop + y,
          child: Opacity(
            opacity: opacity,
            child: Transform(
              alignment: const Alignment(0, -0.6),
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotateY)
                ..rotateZ(rotateZ)
                ..scaleByDouble(scale, scale, 1, 1),
              child: GestureDetector(
                onTap: () {
                  if (index != currentIndex) {
                    onCardSelect(index);
                  }
                },
                child: RepaintBoundary(
                  child: AmanahQueueCardCover(card: cards[index]),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: cardWidgets);
  }
}

class AmanahQueueCardCover extends StatelessWidget {
  const AmanahQueueCardCover({super.key, required this.card, this.width, this.height});

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
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.14)
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
                              AmanahColorTokens.auroraSapphireDark.withValues(alpha: 0.35),
                              AmanahColorTokens.neutral800.withValues(alpha: 0.15),
                              Colors.transparent,
                            ]
                          : <Color>[
                              AmanahColorTokens.brandMuted.withValues(alpha: 0.50),
                              AmanahColorTokens.brandSurface.withValues(alpha: 0.15),
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
                              AmanahColorTokens.brandLight,
                              AmanahColorTokens.brandSoft,
                              AmanahColorTokens.brandSubtle,
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
                          ? AmanahColorTokens.brandSoft
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
                        AmanahColorTokens.surfaceLight.withValues(alpha: isDark ? 0.05 : 0.10),
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
