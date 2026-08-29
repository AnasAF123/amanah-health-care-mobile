import 'dart:ui';
import 'package:flutter/material.dart';

/// GSAP-style Two-Phase Blurry Morphing Text Widget
/// Phase 1 (Exit 180ms): blur(0 -> 8px), scale(1.0 -> 0.94), opacity(1.0 -> 0.0) [Curves.easeIn]
/// Phase 2 (Enter 320ms): blur(8px -> 0), scale(1.06 -> 1.0), opacity(0.0 -> 1.0) [Curves.easeOut]
class BlurryMorphText extends StatefulWidget {
  const BlurryMorphText({
    required this.text,
    required this.style,
    super.key,
    this.textAlign = TextAlign.center,
    this.isProcessing = false,
    this.dotCount = 0,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final bool isProcessing;
  final int dotCount;

  @override
  State<BlurryMorphText> createState() => _BlurryMorphTextState();
}

class _BlurryMorphTextState extends State<BlurryMorphText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late String _currentText;
  late String _targetText;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _targetText = widget.text;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant BlurryMorphText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _targetText = widget.text;
      _triggerMorph();
    }
  }

  void _triggerMorph() {
    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = _controller.value;
        double opacity;
        double scale;
        double blurSigma;

        if (!_controller.isAnimating && t == 0.0) {
          opacity = 1.0;
          scale = 1.0;
          blurSigma = 0.0;
          _currentText = _targetText;
        } else if (t <= 0.36) {
          // Phase 1: Exit Blur (0ms -> 180ms) (180 / 500 = 0.36)
          final double progress = t / 0.36;
          final double ease = Curves.easeIn.transform(progress);
          opacity = 1.0 - ease;
          scale = 1.0 - (0.06 * ease);
          blurSigma = ease * 8.0;
        } else {
          // Phase 2: Enter Sharp (180ms -> 500ms)
          if (_currentText != _targetText) {
            _currentText = _targetText;
          }
          final double progress = (t - 0.36) / 0.64;
          final double ease = Curves.easeOut.transform(progress);
          opacity = ease;
          scale = 1.06 - (0.06 * ease);
          blurSigma = (1.0 - ease) * 8.0;
        }

        Widget content;
        if (widget.isProcessing) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Memproses', style: widget.style, textAlign: widget.textAlign),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text('antrean', style: widget.style),
                  const SizedBox(width: 2),
                  // Monospaced fixed-width dot container to prevent layout shifts & vertical wrapping
                  SizedBox(
                    width: 36,
                    child: Text(
                      '.' * widget.dotCount,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: widget.style.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          content = Text(
            _currentText,
            style: widget.style,
            textAlign: widget.textAlign,
          );
        }

        if (blurSigma <= 0.01) {
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: content,
            ),
          );
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
                tileMode: TileMode.decal,
              ),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
