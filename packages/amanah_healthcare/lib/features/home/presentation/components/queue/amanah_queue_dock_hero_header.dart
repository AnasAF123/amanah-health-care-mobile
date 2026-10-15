import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_blurry_morph_text.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_paramedic_toolbox.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// 3D Paramedic Toolbox and dynamic BlurryMorphText header for Queue Dock
class AmanahQueueDockHeroHeader extends StatelessWidget {
  const AmanahQueueDockHeroHeader({
    super.key,
    required this.textProgress,
    required this.showSuccess,
    required this.isMorphingActive,
    required this.isNearSlot,
    required this.dotCount,
    required this.headlineText,
  });

  final double textProgress;
  final bool showSuccess;
  final bool isMorphingActive;
  final bool isNearSlot;
  final int dotCount;
  final String headlineText;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Transform.translate(
      offset: Offset(0, -15.0 * (1.0 - textProgress)),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showSuccess ? 0.0 : textProgress,
        child: RepaintBoundary(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: const Cubic(0.22, 1.0, 0.36, 1.0),
            transform: Matrix4.translationValues(
              0,
              isMorphingActive ? 220.0 : 12.0,
              0,
            ),
            child: AnimatedScale(
              scale: isMorphingActive ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 700),
              curve: const Cubic(0.22, 1.0, 0.36, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 6),
                  AnimatedScale(
                    scale: (isMorphingActive || isNearSlot) ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: AmanahParamedicToolbox3D(
                      isOpen: isMorphingActive || isNearSlot,
                      size: 76,
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlurryMorphText(
                    text: headlineText,
                    isProcessing: isMorphingActive,
                    dotCount: dotCount,
                    style: TextStyle(
                      color: isNearSlot || isMorphingActive
                          ? (isDark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brandPrimary)
                          : (isDark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
