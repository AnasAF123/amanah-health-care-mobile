import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Resolved visual styling contract for [AmanahStatusBadge] and [AmanahPill].
class AmanahPillStyle {
  const AmanahPillStyle({
    required this.dotColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.shadowColor,
  });

  final Color dotColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color shadowColor;
}

/// Abstract style service providing single source of truth for all pill badges.
abstract final class AmanahPillStyleService {
  /// Resolves the primary indicator color for a badge variant.
  static Color dotColorFor(
    AmanahBadgeVariant variant, {
    BuildContext? context,
    bool? isDark,
  }) {
    final AmanahStatusTone tone = switch (variant) {
      AmanahBadgeVariant.success => AmanahStatusTone.success,
      AmanahBadgeVariant.primary ||
      AmanahBadgeVariant.live =>
        AmanahStatusTone.brand,
      AmanahBadgeVariant.warning => AmanahStatusTone.warning,
      AmanahBadgeVariant.trend => AmanahStatusTone.violet,
    };

    return AmanahThemeTokens.status(
      tone,
      context: context,
      isDark: isDark,
    ).primary;
  }

  /// Resolves the comprehensive styling bundle for a pill component.
  static AmanahPillStyle resolve(
    AmanahBadgeVariant variant, {
    BuildContext? context,
    bool? isDark,
    Color? customDotColor,
  }) {
    final bool dark = isDark ??
        (context != null
            ? Theme.of(context).brightness == Brightness.dark
            : false);

    return AmanahPillStyle(
      dotColor: customDotColor ??
          dotColorFor(variant, context: context, isDark: dark),
      backgroundColor: dark
          ? AmanahColorTokens.canvasDark.withValues(alpha: 0.70)
          : AmanahColorTokens.surfaceLight.withValues(alpha: 0.90),
      borderColor: dark
          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
          : AmanahColorTokens.neutral200,
      textColor: dark
          ? AmanahColorTokens.surfaceLight
          : AmanahColorTokens.neutral900,
      shadowColor: AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
    );
  }
}

/// Pure atomic pill/badge shell matching the signature card-level pill style.
/// Completely agnostic, independent, and token-driven.
class AmanahStatusBadge extends StatelessWidget {
  const AmanahStatusBadge({
    required this.text,
    this.variant = AmanahBadgeVariant.primary,
    this.customDotColor,
    this.enableBlur = true,
    this.padding,
    this.fontSize = 12.0,
    super.key,
  });

  final String text;
  final AmanahBadgeVariant variant;
  final Color? customDotColor;
  final bool enableBlur;
  final EdgeInsetsGeometry? padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final AmanahPillStyle style = AmanahPillStyleService.resolve(
      variant,
      context: context,
      customDotColor: customDotColor,
    );

    final Widget pillBody = Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(AmanahRadius.pill),
        border: Border.all(color: style.borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: style.shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: style.dotColor,
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 8, height: 8),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: style.textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (!enableBlur) {
      return pillBody;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AmanahRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: pillBody,
      ),
    );
  }
}

/// Idiomatic alias for [AmanahStatusBadge].
typedef AmanahPill = AmanahStatusBadge;
