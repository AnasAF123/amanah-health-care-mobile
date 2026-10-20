import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_ticket_painters.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';

/// Molecule: Reusable Ticket Card Shell with 3D crystal architecture texture,
/// C-notch silhouette, liquid glass gradient, dashed perforated line, and specular sheen.
/// Provides an agnostic presentation wrapper for schedule cards, payroll slips, or KPI summaries.
class AmanahTicketCardShell extends StatelessWidget {
  const AmanahTicketCardShell({
    required this.child,
    this.height = AmanahScheduleCardTokens.cardHeight,
    this.showPerforatedLine = true,
    this.onTap,
    this.semanticsLabel,
    this.customShadow,
    super.key,
  });

  final Widget child;
  final double? height;
  final bool showPerforatedLine;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final List<BoxShadow>? customShadow;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String bgAsset = dark
        ? AmanahScheduleCardTokens.bgImageDark
        : AmanahScheduleCardTokens.bgImageLight;

    final List<BoxShadow> effectiveShadow = customShadow ??
        (dark
            ? AmanahScheduleCardTokens.cardShadowDark
            : AmanahScheduleCardTokens.cardShadowLight);

    final Widget coreContent = Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: effectiveShadow),
      child: ClipPath(
        clipper: const AmanahTicketClipper(),
        child: Stack(
          children: <Widget>[
            // Layer 1: Solid Card Base & Outer Border
            Positioned.fill(
              child: CustomPaint(painter: AmanahCardBasePainter(dark: dark)),
            ),

            // Layer 2: Authentic 3D Geometric Crystal Texture Asset
            Positioned.fill(
              child: Image.asset(
                bgAsset,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? const <Color>[
                                AmanahColorTokens.surfaceSecondaryDark,
                                AmanahColorTokens.canvasDark,
                              ]
                            : const <Color>[
                                AmanahColorTokens.brandSurface,
                                AmanahColorTokens.canvasLight,
                              ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Layer 3: Seamless Liquid Glass Gradient Mask
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: dark
                      ? AmanahScheduleCardTokens.liquidGlassGradientDark
                      : AmanahScheduleCardTokens.liquidGlassGradientLight,
                ),
              ),
            ),

            // Layer 4: Top-to-Bottom Glass Specular Sheen
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: dark
                      ? AmanahScheduleCardTokens.glassSpecularSheenDark
                      : AmanahScheduleCardTokens.glassSpecularSheenLight,
                ),
              ),
            ),

            // Layer 5: Wall-to-Wall Perforated Dashed Line between C-Notches
            if (showPerforatedLine)
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahPerforatedLinePainter(dark: dark),
                ),
              ),

            // Layer 6: Foreground Content & Optional InkWell
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    if (semanticsLabel != null) {
      return Semantics(
        label: semanticsLabel,
        child: coreContent,
      );
    }

    return coreContent;
  }
}
