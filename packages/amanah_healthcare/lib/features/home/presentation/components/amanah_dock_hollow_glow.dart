import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// 6-Layer Volumetric Optical Glow Painter for the Bottom Dock Hollow Slot
/// Matches the web specification in BottomNotchedDock.tsx and Recessed3DSlot.tsx
class AmanahDockHollowGlowPainter extends CustomPainter {
  const AmanahDockHollowGlowPainter({
    required this.dragProgress,
    required this.isLongPressing,
    required this.isActivating,
    this.isDark = false,
  });

  final double dragProgress;
  final bool isLongPressing;
  final bool isActivating;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double scaleX = w / 390.0;
    final double scaleY = h / 145.0;

    final double activeProgress = isActivating
        ? 1.0
        : dragProgress.clamp(0.0, 1.0);

    canvas.save();
    canvas.scale(scaleX, scaleY);

    if (isLongPressing || activeProgress > 0.02) {
      final double auraProgress = isLongPressing ? 1.0 : activeProgress;
      final double risingFactor = Curves.easeOutCubic.transform(auraProgress);
      final double auraOpacity = isLongPressing ? 0.95 : (risingFactor * 0.90);

      const double beamBottomY = 48.0;
      final double beamTopY = 38.0 - (175.0 * risingFactor);
      final double beamHeight = (beamBottomY - beamTopY).clamp(20.0, 220.0);
      final double beamCenterY = beamTopY + (beamHeight / 2.0);
      final double beamWidth = 190.0 + (75.0 * risingFactor);

      final Paint risingAuraPaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.linear(
          const Offset(195, beamBottomY),
          Offset(195, beamTopY),
          <Color>[
            AmanahColorTokens.brandAccent.withValues(
              alpha: 0.85 * auraOpacity,
            ),
            AmanahColorTokens.auroraAccentDark.withValues(
              alpha: 0.60 * auraOpacity,
            ),
            AmanahColorTokens.brandLight.withValues(
              alpha: 0.30 * auraOpacity,
            ),
            AmanahColorTokens.brandLight.withValues(alpha: 0.0),
          ],
          <double>[0.0, 0.35, 0.70, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);

      final Rect risingAuraRect = Rect.fromCenter(
        center: Offset(195, beamCenterY),
        width: beamWidth,
        height: beamHeight,
      );
      canvas.drawOval(risingAuraRect, risingAuraPaint);

      const double coreBottomY = 44.0;
      final double coreTopY = 36.0 - (105.0 * risingFactor);
      final double coreHeight = (coreBottomY - coreTopY).clamp(15.0, 150.0);
      final double coreCenterY = coreTopY + (coreHeight / 2.0);
      final double coreWidth = 160.0 + (45.0 * risingFactor);

      final Paint innerCorePaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.linear(
          const Offset(195, coreBottomY),
          Offset(195, coreTopY),
          <Color>[
            AmanahColorTokens.brandPrimary.withValues(
              alpha: 0.80 * auraOpacity,
            ),
            AmanahColorTokens.brandLight.withValues(
              alpha: 0.55 * auraOpacity,
            ),
            AmanahColorTokens.brandLight.withValues(alpha: 0.0),
          ],
          <double>[0.0, 0.60, 1.0],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

      final Rect innerCoreRect = Rect.fromCenter(
        center: Offset(195, coreCenterY),
        width: coreWidth,
        height: coreHeight,
      );
      canvas.drawOval(innerCoreRect, innerCorePaint);
    }

    final double domeFactor = Curves.easeOutCubic.transform(activeProgress);
    final double domeScale = isLongPressing ? 1.08 : (0.90 + domeFactor * 0.30);
    final double domeOpacity = isLongPressing
        ? 0.75
        : (0.20 + domeFactor * 0.50);
    final Paint domePaint = Paint()
      ..blendMode = BlendMode.screen
      ..shader = ui.Gradient.linear(
        const Offset(195, 80),
        const Offset(195, -30),
        <Color>[
          AmanahColorTokens.brandPrimary.withValues(
            alpha: 0.65 * domeOpacity,
          ),
          AmanahColorTokens.brandLight.withValues(alpha: 0.40 * domeOpacity),
          AmanahColorTokens.brandLight.withValues(alpha: 0.0),
        ],
        <double>[0.0, 0.55, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final Rect domeRect = Rect.fromCenter(
      center: const Offset(195, 25),
      width: 245 * domeScale,
      height: 150 * domeScale,
    );
    canvas.drawOval(domeRect, domePaint);

    final double apertureOpacity = isLongPressing
        ? 1.0
        : (0.45 + activeProgress * 0.55);
    final Paint aperturePaint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(195, 42),
        120,
        <Color>[
          AmanahColorTokens.brandLight.withValues(alpha: apertureOpacity),
          AmanahColorTokens.brandPrimary.withValues(
            alpha: apertureOpacity * 0.60,
          ),
          AmanahColorTokens.brandPrimary.withValues(alpha: 0.0),
        ],
        <double>[0.0, 0.60, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(195, 42),
        width: isLongPressing ? 245 : 235,
        height: 45,
      ),
      aperturePaint,
    );

    // =========================================================================
    // LAYER 3: RECESSED HOLLOW CAVITY (DEEP CONTRAST MASK)
    // =========================================================================
    final Path cavityPath = Path()
      ..moveTo(73, 10)
      ..quadraticBezierTo(81, 10, 83, 18)
      ..lineTo(86, 30)
      ..quadraticBezierTo(89, 40, 100, 40)
      ..lineTo(290, 40)
      ..quadraticBezierTo(301, 40, 304, 30)
      ..lineTo(307, 18)
      ..quadraticBezierTo(309, 10, 317, 10)
      ..lineTo(317, 55)
      ..lineTo(73, 55)
      ..close();

    final Paint cavityPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(195, 10),
        const Offset(195, 55),
        const <Color>[
          AmanahColorTokens.dockCavityDark,
          AmanahColorTokens.dockCavityDeep,
        ],
      );
    canvas.drawPath(cavityPath, cavityPaint);

    final Path surfacePath = Path()
      ..moveTo(0, 10)
      ..lineTo(73, 10)
      ..quadraticBezierTo(81, 10, 83, 18)
      ..lineTo(86, 30)
      ..quadraticBezierTo(89, 40, 100, 40)
      ..lineTo(290, 40)
      ..quadraticBezierTo(301, 40, 304, 30)
      ..lineTo(307, 18)
      ..quadraticBezierTo(309, 10, 317, 10)
      ..lineTo(390, 10)
      ..lineTo(390, 145)
      ..lineTo(0, 145)
      ..close();

    final Paint surfacePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(195, 0),
        const Offset(195, 145),
        isDark
            ? const <Color>[
                AmanahColorTokens.dockSurfaceDarkTop,
                AmanahColorTokens.dockSurfaceDarkMid,
                AmanahColorTokens.dockSurfaceDarkBottom,
              ]
            : const <Color>[
                AmanahColorTokens.neutral200,
                AmanahColorTokens.neutral300,
                AmanahColorTokens.neutral400,
              ],
        const <double>[0.0, 0.35, 1.0],
      );
    canvas.drawPath(surfacePath, surfacePaint);

    final Path contourLipPath = Path()
      ..moveTo(0, 10)
      ..lineTo(73, 10)
      ..quadraticBezierTo(81, 10, 83, 18)
      ..lineTo(86, 30)
      ..quadraticBezierTo(89, 40, 100, 40)
      ..lineTo(290, 40)
      ..quadraticBezierTo(301, 40, 304, 30)
      ..lineTo(307, 18)
      ..quadraticBezierTo(309, 10, 317, 10)
      ..lineTo(390, 10);

    final Shader contourGlowShader = ui.Gradient.linear(
      Offset.zero,
      const Offset(390, 0),
      <Color>[
        AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.0),
        AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.40),
        AmanahColorTokens.brandLight.withValues(alpha: 0.85),
        AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.40),
        AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.0),
      ],
      const <double>[0.0, 0.22, 0.50, 0.78, 1.0],
    );

    final Paint diffusePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..shader = contourGlowShader
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawPath(contourLipPath, diffusePaint);

    final Paint crispRimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.85
      ..shader = contourGlowShader;
    canvas.drawPath(contourLipPath, crispRimPaint);

    if (isLongPressing || activeProgress > 0.05) {
      final Path filamentPath = Path()
        ..moveTo(100, 40)
        ..lineTo(290, 40);

      final Shader filamentShader = ui.Gradient.linear(
        const Offset(100, 0),
        const Offset(290, 0),
        <Color>[
          AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.0),
          AmanahColorTokens.brandLight.withValues(alpha: 0.90),
          AmanahColorTokens.brandMuted,
          AmanahColorTokens.brandLight.withValues(alpha: 0.90),
          AmanahColorTokens.auroraAccentDark.withValues(alpha: 0.0),
        ],
        const <double>[0.0, 0.25, 0.50, 0.75, 1.0],
      );

      final Paint moltenGlowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isLongPressing ? 8.0 : 5.0
        ..shader = filamentShader
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawPath(filamentPath, moltenGlowPaint);

      final Paint coreLaserPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isLongPressing ? 3.0 : 1.85
        ..shader = filamentShader;
      canvas.drawPath(filamentPath, coreLaserPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AmanahDockHollowGlowPainter oldDelegate) {
    return oldDelegate.dragProgress != dragProgress ||
        oldDelegate.isLongPressing != isLongPressing ||
        oldDelegate.isActivating != isActivating ||
        oldDelegate.isDark != isDark;
  }
}
