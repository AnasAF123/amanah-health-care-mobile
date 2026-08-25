import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/state/password_requirements.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    required this.controller,
    super.key,
    this.showWhenEmpty = false,
  });

  final TextEditingController controller;
  final bool showWhenEmpty;

  static const Duration _duration = Duration(milliseconds: 260);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        final String password = value.text;
        final bool visible = showWhenEmpty || password.isNotEmpty;
        final PasswordRequirementEvaluation evaluation =
            AmanahPasswordRequirements.evaluate(password);

        return AnimatedSize(
          duration: _duration,
          curve: _curve,
          alignment: Alignment.topCenter,
          child: visible
              ? Padding(
                  padding: const EdgeInsets.only(top: SMALL_SPACE),
                  child: AnimatedSwitcher(
                    duration: _duration,
                    switchInCurve: _curve,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: _buildTransition,
                    child: _PasswordStrengthCard(
                      key: ValueKey<String>(
                        evaluation.isComplete
                            ? 'complete'
                            : evaluation.firstUnmet?.label ?? 'empty',
                      ),
                      evaluation: evaluation,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final Animation<Offset> offset = Tween<Offset>(
      begin: const Offset(0, -0.18),
      end: Offset.zero,
    ).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: offset,
        child: AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (BuildContext context, Widget? animatedChild) {
            final double blur = 2 * (1 - animation.value);
            return ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: animatedChild ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordStrengthCard extends StatelessWidget {
  const _PasswordStrengthCard({required this.evaluation, super.key});

  final PasswordRequirementEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool complete = evaluation.isComplete;
    final Color accentColor = complete
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.46);
    final String label = complete
        ? 'Password lengkap, silakan lanjutkan'
        : evaluation.firstUnmet?.label ?? 'Minimal 8 karakter';
    final String semanticLabel =
        '$label. ${evaluation.completedCount} dari ${evaluation.totalCount} syarat terpenuhi.';

    return Semantics(
      liveRegion: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.70 : 0.76,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(
                  alpha: complete ? 0.28 : 0.42,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MEDIUM_SPACE,
                vertical: SMALL_SPACE,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        _PasswordMeterDot(complete: complete),
                        const SizedBox(width: SMALL_SPACE),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: complete
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.72,
                                    ),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  Icon(
                    complete
                        ? Icons.check_circle_outline_rounded
                        : Icons.gpp_maybe_outlined,
                    size: 15,
                    color: accentColor,
                  ),
                  const SizedBox(width: VERY_SMALL_SPACE),
                  Text(
                    '${evaluation.completedCount}/${evaluation.totalCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
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

class _PasswordMeterDot extends StatelessWidget {
  const _PasswordMeterDot({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accentColor = complete
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.48);

    return AnimatedContainer(
      duration: PasswordStrengthMeter._duration,
      curve: PasswordStrengthMeter._curve,
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: complete
            ? accentColor.withValues(alpha: 0.14)
            : theme.colorScheme.onSurface.withValues(alpha: 0.10),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: PasswordStrengthMeter._duration,
          child: complete
              ? Icon(
                  Icons.check_rounded,
                  key: const ValueKey<String>('complete'),
                  size: 12,
                  color: accentColor,
                )
              : DecoratedBox(
                  key: const ValueKey<String>('pending'),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                  child: const SizedBox(width: 6, height: 6),
                ),
        ),
      ),
    );
  }
}
