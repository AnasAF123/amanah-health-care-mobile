import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Style variants for [AmanahSlideToConfirm]
enum AmanahSlideVariant { brandGradient, outline, surface }

/// An agnostic, token-driven "Slide To Action" confirmation widget.
/// Inspired by the 1:1 Aero Glass design specification in docs/my-taste/slider/index.html.
class AmanahSlideToConfirm extends StatefulWidget {
  const AmanahSlideToConfirm({
    required this.onConfirmed,
    this.text = 'Geser untuk Konfirmasi',
    this.targetText,
    this.completedText = 'Terkonfirmasi!',
    this.variant = AmanahSlideVariant.brandGradient,
    this.height = 52.0,
    this.isLoading = false,
    this.isCompleted = false,
    this.isDisabled = false,
    this.enableHaptics = true,
    this.borderRadius,
    super.key,
  });

  final Future<dynamic> Function() onConfirmed;
  final String text;
  final String? targetText;
  final String completedText;
  final AmanahSlideVariant variant;
  final double height;
  final bool isLoading;
  final bool isCompleted;
  final bool isDisabled;
  final bool enableHaptics;
  final BorderRadius? borderRadius;

  @override
  State<AmanahSlideToConfirm> createState() => _AmanahSlideToConfirmState();
}

class _AmanahSlideToConfirmState extends State<AmanahSlideToConfirm> with TickerProviderStateMixin {
  late final AnimationController _resetController;
  late final AnimationController _chevronController;
  late Animation<double> _resetAnimation;

  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _internalCompleted = false;

  static const double _knobPadding = 4.0;
  static const double _completeThreshold = 0.85;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant AmanahSlideToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !_internalCompleted) {
      setState(() => _internalCompleted = true);
    } else if (!widget.isCompleted && _internalCompleted) {
      _resetSlider();
    }
  }

  @override
  void dispose() {
    _resetController.dispose();
    _chevronController.dispose();
    super.dispose();
  }

  void _resetSlider() {
    if (!mounted) return;
    _resetAnimation =
        Tween<double>(begin: _dragPosition, end: 0.0).animate(
          CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
        )..addListener(() {
          setState(() {
            _dragPosition = _resetAnimation.value;
          });
        });

    _resetController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _dragPosition = 0.0;
          _internalCompleted = false;
        });
      }
    });
  }

  void _onDragStart(DragStartDetails details) {
    if (widget.isDisabled || widget.isLoading || widget.isCompleted || _internalCompleted) {
      return;
    }
    _resetController.stop();
    setState(() => _isDragging = true);
    if (widget.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!_isDragging ||
        widget.isDisabled ||
        widget.isLoading ||
        widget.isCompleted ||
        _internalCompleted) {
      return;
    }

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });

    // Pure logic: triggers completion when knob reaches the 100% right edge
    if (_dragPosition >= maxDrag && !_internalCompleted) {
      _triggerCompletion(maxDrag);
    }
  }

  void _onDragEnd(DragEndDetails details, double maxDrag) {
    if (!_isDragging) return;
    setState(() => _isDragging = false);

    if (_dragPosition >= maxDrag * _completeThreshold) {
      _triggerCompletion(maxDrag);
    } else {
      _resetSlider();
    }
  }

  Future<void> _triggerCompletion(double maxDrag) async {
    setState(() {
      _dragPosition = maxDrag;
      _internalCompleted = true;
      _isDragging = false;
    });

    if (widget.enableHaptics) {
      HapticFeedback.heavyImpact();
    }

    // Momentary pause so the user can perceive the knob at the right edge and full target text opacity
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;

    try {
      final dynamic result = await widget.onConfirmed();
      if (result == false && mounted) {
        _resetSlider();
      }
    } catch (_) {
      if (mounted) {
        _resetSlider();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double knobSize = widget.height - 2.0 - (_knobPadding * 2);
    final BorderRadius effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxDrag = math.max(0.0, maxWidth - knobSize - (_knobPadding * 2));
        final double progress = maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;
        final double promptOpacity = math.max(0.0, 1.0 - (progress * 1.5));
        final double targetOpacity = Curves.easeIn.transform(progress);

        // Resolved styling based on variant and theme
        final BoxDecoration trackDecoration = _resolveTrackDecoration(dark, effectiveRadius);

        return Opacity(
          opacity: widget.isDisabled ? 0.45 : 1.0,
          child: Container(
            height: widget.height,
            width: maxWidth,
            decoration: trackDecoration,
            child: ClipRRect(
              borderRadius: effectiveRadius,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  // 1. Drag fill glow layer
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _dragPosition + knobSize + _knobPadding,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.white.withValues(alpha: dark ? 0.08 : 0.22),
                            AmanahColorTokens.brand.withValues(alpha: dark ? 0.15 : 0.28),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Center Content: Chevrons + Text with Crossfade
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // (a) Initial Prompt Text (Fades out 1.0 -> 0.0)
                        AnimatedOpacity(
                          opacity: _internalCompleted ? 0.0 : promptOpacity,
                          duration: const Duration(milliseconds: 60),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: knobSize / 1.5),
                              AnimatedBuilder(
                                animation: _chevronController,
                                builder: (BuildContext context, Widget? child) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List<Widget>.generate(3, (int i) {
                                      final double animVal =
                                          (_chevronController.value - (i * 0.2)) % 1.0;
                                      final double opacity = (math.sin(
                                        animVal * math.pi,
                                      )).clamp(0.25, 1.0);
                                      return Opacity(
                                        opacity: opacity,
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: _resolveTextColor(dark),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.1,
                                    color: _resolveTextColor(dark),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),

                        // (b) Target Text (Fades in 0.0 -> 1.0, reaching 100% full opacity at right edge)
                        if (widget.targetText != null)
                          AnimatedOpacity(
                            opacity: _internalCompleted ? 0.0 : targetOpacity,
                            duration: const Duration(milliseconds: 60),
                            child: Padding(
                              padding: EdgeInsets.only(right: knobSize / 1.5),
                              child: Text(
                                widget.targetText!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                  color: _resolveTextColor(dark),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 3. Completed State Overlay Text
                  if (_internalCompleted)
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            widget.completedText,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 4. Skeuomorphic 3D Convex Squircle Knob
                  Positioned(
                    left: _knobPadding + _dragPosition,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onHorizontalDragStart: _onDragStart,
                        onHorizontalDragUpdate: (DragUpdateDetails d) => _onDragUpdate(d, maxDrag),
                        onHorizontalDragEnd: (DragEndDetails d) => _onDragEnd(d, maxDrag),
                        child: _buildSkeuomorphicKnob(knobSize, dark, effectiveRadius),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeuomorphicKnob(double size, bool dark, BorderRadius trackRadius) {
    final bool completed = _internalCompleted || widget.isCompleted;
    final double innerRadiusValue = math.max(6.0, trackRadius.topLeft.x - _knobPadding);
    final BorderRadius knobRadius = BorderRadius.circular(innerRadiusValue);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: knobRadius,
        // Tactile Convex (Cembung 3D Apple-contour) raised lighting
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: completed
              ? <Color>[AmanahColorTokens.brand, AmanahColorTokens.brandNavy]
              : <Color>[
                  Colors.white,
                  dark ? const Color(0xFFF1F6FD) : const Color(0xFFF8FAFC),
                  dark ? const Color(0xFFD6E3F4) : const Color(0xFFE2E8F0),
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AmanahColorTokens.pureBlack.withValues(alpha: dark ? 0.40 : 0.16),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: AmanahColorTokens.brand.withValues(alpha: dark ? 0.25 : 0.15),
            blurRadius: 8,
            offset: const Offset(1, 1),
          ),
        ],
        border: Border.all(
          color: completed
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.95),
          width: 1.2,
        ),
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AmanahColorTokens.brand),
                ),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (Widget child, Animation<double> anim) {
                  return ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        key: ValueKey<String>('check'),
                        size: 20,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.arrow_forward_rounded,
                        key: const ValueKey<String>('arrow'),
                        size: 20,
                        color: AmanahColorTokens.brand,
                      ),
              ),
      ),
    );
  }

  BoxDecoration _resolveTrackDecoration(bool dark, BorderRadius radius) {
    switch (widget.variant) {
      case AmanahSlideVariant.brandGradient:
        return BoxDecoration(
          borderRadius: radius,
          gradient: dark
              ? AmanahColorTokens.btnCrispBlueDarkGradient
              : AmanahColorTokens.btnCrispBlueGradient,
          border: Border.all(
            color: dark
                ? AmanahColorTokens.btnCrispBlueDarkBorder
                : AmanahColorTokens.btnCrispBlueBorder,
            width: 1.0,
          ),
          boxShadow: <BoxShadow>[
            AmanahColorTokens.btnCrispDropShadow,
            if (dark)
              AmanahColorTokens.btnCrispBlueDarkShadow
            else
              AmanahColorTokens.btnCrispBlueShadow,
          ],
        );

      case AmanahSlideVariant.outline:
        return BoxDecoration(
          borderRadius: radius,
          color: dark ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                : AmanahColorTokens.neutral300,
            width: 1.0,
          ),
        );

      case AmanahSlideVariant.surface:
        return BoxDecoration(
          borderRadius: radius,
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
              : AmanahColorTokens.neutral100,
          border: Border.all(
            color: dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
                : AmanahColorTokens.neutral200,
            width: 1.0,
          ),
        );
    }
  }

  Color _resolveTextColor(bool dark) {
    switch (widget.variant) {
      case AmanahSlideVariant.brandGradient:
        return Colors.white;
      case AmanahSlideVariant.outline:
      case AmanahSlideVariant.surface:
        return dark ? Colors.white : AmanahColorTokens.neutral900;
    }
  }
}
