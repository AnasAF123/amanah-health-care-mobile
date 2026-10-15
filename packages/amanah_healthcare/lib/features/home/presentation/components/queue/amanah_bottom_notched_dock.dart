import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_dock_hollow_glow.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahBottomNotchedDock extends StatelessWidget {
  const AmanahBottomNotchedDock({
    super.key,
    required this.isActivating,
    required this.dragProgress,
    required this.isLongPressing,
    required this.label,
  });

  final bool isActivating;
  final double dragProgress;
  final bool isLongPressing;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, isActivating ? 180.0 : 0.0, 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isActivating ? 0.0 : 1.0,
        child: SizedBox(
          height: 145,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahDockHollowGlowPainter(
                    dragProgress: dragProgress,
                    isLongPressing: isLongPressing,
                    isActivating: isActivating,
                    isDark: isDark,
                  ),
                ),
              ),

              Positioned(
                top: 66,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isActivating ? 0.0 : 1.0,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dragProgress > 0.05
                          ? AmanahColorTokens.brandLight
                          : (isDark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral700),
                      fontSize: 12,
                      fontWeight: dragProgress > 0.05
                          ? FontWeight.w800
                          : FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: dragProgress > 0.05
                          ? const <Shadow>[
                              Shadow(color: AmanahColorTokens.brandLight, blurRadius: 12),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 10,
                child: Container(
                  width: 112,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.25)
                        : AmanahColorTokens.pureBlack.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
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
