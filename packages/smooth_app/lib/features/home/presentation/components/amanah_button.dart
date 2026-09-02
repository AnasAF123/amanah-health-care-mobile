import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Master Button Variants for the Amanah Healthcare Design System
enum AmanahButtonVariant {
  /// Bold established blue gradient with specular sheen & shadow
  primary,

  /// Filled destructive action for confirmed dangerous flows
  destructive,

  /// Subtle soft-blue tinted surface button
  secondary,

  /// Clean stroke-only bordered button (1.5px border)
  outline,

  /// Transparent background with hover/tap effect
  ghost,

  /// Plain text-only button with zero container padding
  text,

  /// Circular or rounded-square icon-only action button
  icon,

  /// Custom vector/canvas graphic action button
  vectorOnly,
}

/// Master Button Sizing Scales
enum AmanahButtonSize {
  /// Height: 48dp, font: 12px, icon: 16px, padding: H12
  small,

  /// Height: 48dp, font: 14px, icon: 18px, padding: H16
  medium,

  /// Height: 52dp, font: 15px, icon: 20px, padding: H20
  large,

  /// Height: 56dp, font: 16px, icon: 22px, padding: H24
  hero,
}

/// Master Button Component (Single Source of Truth for all buttons)
/// All button variants inherit from this master component.
class AmanahButton extends StatelessWidget {
  const AmanahButton({
    super.key,
    this.text,
    this.onPressed,
    this.variant = AmanahButtonVariant.primary,
    this.size = AmanahButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.trailingText,
    this.vectorChild,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.isCircle = false,
    this.customHeight,
    this.customWidth,
    this.borderRadius,
    this.customBackgroundColor,
    this.customForegroundColor,
    this.customGradient,
    this.customBorder,
    this.boxShadow,
    this.semanticsLabel,
    this.enableHaptics = true,
  });

  /// Factory: Primary Bold Button (Gradient / Solid Blue)
  const AmanahButton.primary({
    Key? key,
    String? text,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    String? trailingText,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    double? customHeight,
    double? customWidth,
    BorderRadius? borderRadius,
    Gradient? customGradient,
    List<BoxShadow>? boxShadow,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.primary,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         trailingText: trailingText,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         customHeight: customHeight,
         customWidth: customWidth,
         borderRadius: borderRadius,
         customGradient: customGradient,
         boxShadow: boxShadow,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Destructive Filled Button
  const AmanahButton.destructive({
    Key? key,
    String? text,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    String? trailingText,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    double? customHeight,
    double? customWidth,
    BorderRadius? borderRadius,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.destructive,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         trailingText: trailingText,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         customHeight: customHeight,
         customWidth: customWidth,
         borderRadius: borderRadius,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Secondary / Subtle Blue Button
  const AmanahButton.secondary({
    Key? key,
    String? text,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    String? trailingText,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    double? customHeight,
    double? customWidth,
    BorderRadius? borderRadius,
    Color? customBackgroundColor,
    Color? customForegroundColor,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.secondary,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         trailingText: trailingText,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         customHeight: customHeight,
         customWidth: customWidth,
         borderRadius: borderRadius,
         customBackgroundColor: customBackgroundColor,
         customForegroundColor: customForegroundColor,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Stroke-Only / Outlined Button
  const AmanahButton.outline({
    Key? key,
    String? text,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    String? trailingText,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    double? customHeight,
    double? customWidth,
    BorderRadius? borderRadius,
    Color? customForegroundColor,
    Border? customBorder,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.outline,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         trailingText: trailingText,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         customHeight: customHeight,
         customWidth: customWidth,
         borderRadius: borderRadius,
         customForegroundColor: customForegroundColor,
         customBorder: customBorder,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Ghost / Transparent Button
  const AmanahButton.ghost({
    Key? key,
    String? text,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    String? trailingText,
    bool isLoading = false,
    bool isDisabled = false,
    bool isFullWidth = false,
    double? customHeight,
    double? customWidth,
    BorderRadius? borderRadius,
    Color? customForegroundColor,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.ghost,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         trailingText: trailingText,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isFullWidth: isFullWidth,
         customHeight: customHeight,
         customWidth: customWidth,
         borderRadius: borderRadius,
         customForegroundColor: customForegroundColor,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Text-Only Button
  const AmanahButton.text({
    required String text,
    Key? key,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    dynamic leadingIcon,
    dynamic trailingIcon,
    bool isLoading = false,
    bool isDisabled = false,
    Color? customForegroundColor,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         variant: AmanahButtonVariant.text,
         size: size,
         leadingIcon: leadingIcon,
         trailingIcon: trailingIcon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         customForegroundColor: customForegroundColor,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Icon-Only Action Button (Circular or Rounded)
  const AmanahButton.icon({
    required dynamic icon,
    Key? key,
    VoidCallback? onPressed,
    AmanahButtonSize size = AmanahButtonSize.medium,
    bool isCircle = true,
    bool isLoading = false,
    bool isDisabled = false,
    double? customSize,
    Color? customBackgroundColor,
    Color? customForegroundColor,
    Border? customBorder,
    List<BoxShadow>? boxShadow,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         leadingIcon: icon,
         onPressed: onPressed,
         variant: AmanahButtonVariant.icon,
         size: size,
         isCircle: isCircle,
         isLoading: isLoading,
         isDisabled: isDisabled,
         customHeight: customSize,
         customWidth: customSize,
         customBackgroundColor: customBackgroundColor,
         customForegroundColor: customForegroundColor,
         customBorder: customBorder,
         boxShadow: boxShadow,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  /// Factory: Custom Vector / Painter Action Button
  const AmanahButton.vectorOnly({
    required Widget vectorChild,
    Key? key,
    VoidCallback? onPressed,
    double? width,
    double? height,
    bool isDisabled = false,
    String? semanticsLabel,
    bool enableHaptics = true,
  }) : this(
         key: key,
         vectorChild: vectorChild,
         onPressed: onPressed,
         variant: AmanahButtonVariant.vectorOnly,
         isDisabled: isDisabled,
         customWidth: width,
         customHeight: height,
         semanticsLabel: semanticsLabel,
         enableHaptics: enableHaptics,
       );

  final String? text;
  final VoidCallback? onPressed;
  final AmanahButtonVariant variant;
  final AmanahButtonSize size;
  final dynamic leadingIcon; // IconData or Widget
  final dynamic trailingIcon; // IconData or Widget
  final String? trailingText;
  final Widget? vectorChild;
  final bool isLoading;
  final bool isDisabled;
  final bool isFullWidth;
  final bool isCircle;
  final double? customHeight;
  final double? customWidth;
  final BorderRadius? borderRadius;
  final Color? customBackgroundColor;
  final Color? customForegroundColor;
  final Gradient? customGradient;
  final Border? customBorder;
  final List<BoxShadow>? boxShadow;
  final String? semanticsLabel;
  final bool enableHaptics;

  double get _height {
    if (customHeight != null) {
      return customHeight!;
    }
    switch (size) {
      case AmanahButtonSize.small:
        return AmanahComponentSize.buttonSmall;
      case AmanahButtonSize.medium:
        return AmanahComponentSize.buttonMedium;
      case AmanahButtonSize.large:
        return AmanahComponentSize.buttonLarge;
      case AmanahButtonSize.hero:
        return AmanahComponentSize.buttonHero;
    }
  }

  double get _fontSize {
    switch (size) {
      case AmanahButtonSize.small:
        return 12.0;
      case AmanahButtonSize.medium:
        return 14.0;
      case AmanahButtonSize.large:
        return 15.0;
      case AmanahButtonSize.hero:
        return 16.0;
    }
  }

  double get _iconSize {
    switch (size) {
      case AmanahButtonSize.small:
        return 16.0;
      case AmanahButtonSize.medium:
        return 18.0;
      case AmanahButtonSize.large:
        return 20.0;
      case AmanahButtonSize.hero:
        return 22.0;
    }
  }

  EdgeInsetsGeometry get _padding {
    if (variant == AmanahButtonVariant.text) {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
    if (variant == AmanahButtonVariant.icon) {
      return EdgeInsets.zero;
    }
    switch (size) {
      case AmanahButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12);
      case AmanahButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AmanahButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20);
      case AmanahButtonSize.hero:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  BorderRadius get _resolvedBorderRadius {
    if (isCircle) {
      return BorderRadius.circular(_height / 2);
    }
    if (borderRadius != null) {
      return borderRadius!;
    }
    switch (size) {
      case AmanahButtonSize.small:
        return BorderRadius.circular(10.0);
      case AmanahButtonSize.medium:
        return BorderRadius.circular(14.0);
      case AmanahButtonSize.large:
        return BorderRadius.circular(16.0);
      case AmanahButtonSize.hero:
        return BorderRadius.circular(18.0);
    }
  }

  void _handleTap() {
    if (isDisabled || isLoading || onPressed == null) {
      return;
    }
    if (enableHaptics) {
      HapticFeedback.selectionClick();
    }
    onPressed!();
  }

  Widget _buildIconWidget(dynamic icon, Color color) {
    if (icon is IconData) {
      return Icon(icon, size: _iconSize, color: color);
    }
    if (icon is Widget) {
      return SizedBox(width: _iconSize, height: _iconSize, child: icon);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final bool effectiveDisabled = isDisabled || onPressed == null;

    // Vector-only variant shortcut
    if (variant == AmanahButtonVariant.vectorOnly && vectorChild != null) {
      return Semantics(
        button: true,
        enabled: !effectiveDisabled,
        label: semanticsLabel ?? text,
        child: SizedBox(
          width: customWidth,
          height: customHeight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveDisabled ? null : _handleTap,
              borderRadius: _resolvedBorderRadius,
              child: Opacity(
                opacity: effectiveDisabled ? 0.45 : 1.0,
                child: vectorChild ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );
    }

    // Color Resolution based on Variant & Theme
    Color fgColor;
    Color? bgColor;
    Gradient? gradient;
    Border? border = customBorder;
    List<BoxShadow>? shadows = boxShadow;

    switch (variant) {
      case AmanahButtonVariant.primary:
        fgColor = customForegroundColor ?? Colors.white;
        gradient =
            customGradient ??
            (dark
                ? AmanahColorTokens.btnCrispBlueDarkGradient
                : AmanahColorTokens.btnCrispBlueGradient);
        border =
            border ??
            Border.all(
              color: dark
                  ? AmanahColorTokens.btnCrispBlueDarkBorder
                  : AmanahColorTokens.btnCrispBlueBorder,
              width: 1.0,
            );
        shadows =
            shadows ??
            <BoxShadow>[
              AmanahColorTokens.btnCrispDropShadow,
              if (dark)
                AmanahColorTokens.btnCrispBlueDarkShadow
              else
                AmanahColorTokens.btnCrispBlueShadow,
            ];
        break;

      case AmanahButtonVariant.destructive:
        fgColor = customForegroundColor ?? Colors.white;
        gradient =
            customGradient ??
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                AmanahColorTokens.danger,
                AmanahColorTokens.dangerDark,
              ],
            );
        border =
            border ??
            Border.all(color: AmanahColorTokens.dangerDark, width: 1.0);
        shadows =
            shadows ??
            <BoxShadow>[
              AmanahColorTokens.btnCrispDropShadow,
              BoxShadow(
                color: AmanahColorTokens.danger.withValues(alpha: 0.24),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ];
        break;

      case AmanahButtonVariant.secondary:
        fgColor =
            customForegroundColor ??
            (dark ? AmanahColorTokens.brandSubtle : AmanahColorTokens.brand);
        bgColor =
            customBackgroundColor ??
            (dark
                ? AmanahColorTokens.neutral700
                : AmanahColorTokens.brandSurface);
        border =
            border ??
            Border.all(
              color: dark
                  ? AmanahColorTokens.neutral600
                  : AmanahColorTokens.brandMuted,
              width: 1.2,
            );
        break;

      case AmanahButtonVariant.outline:
        fgColor =
            customForegroundColor ??
            (dark ? AmanahColorTokens.brandSubtle : AmanahColorTokens.brand);
        bgColor =
            customBackgroundColor ??
            (dark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.85));
        border =
            border ??
            Border.all(
              color: dark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
              width: 1.5,
            );
        break;

      case AmanahButtonVariant.ghost:
        fgColor =
            customForegroundColor ??
            (dark ? AmanahColorTokens.brandSubtle : AmanahColorTokens.brand);
        bgColor = customBackgroundColor ?? Colors.transparent;
        break;

      case AmanahButtonVariant.text:
        fgColor =
            customForegroundColor ??
            (dark ? AmanahColorTokens.brandSubtle : AmanahColorTokens.brand);
        bgColor = Colors.transparent;
        break;

      case AmanahButtonVariant.icon:
        fgColor =
            customForegroundColor ??
            (dark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A));
        bgColor =
            customBackgroundColor ??
            (dark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEFF6FF));
        border =
            border ??
            Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFDBEAFE),
              width: 1.0,
            );
        break;

      case AmanahButtonVariant.vectorOnly:
        fgColor = customForegroundColor ?? Colors.white;
        break;
    }

    if (effectiveDisabled) {
      fgColor = fgColor.withValues(alpha: 0.45);
      if (bgColor != null && bgColor != Colors.transparent) {
        bgColor = bgColor.withValues(alpha: 0.50);
      }
    }

    // Inner Content Builder
    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else if (variant == AmanahButtonVariant.icon) {
      content = Center(child: _buildIconWidget(leadingIcon, fgColor));
    } else {
      final List<Widget> children = <Widget>[];

      if (leadingIcon != null) {
        children.add(_buildIconWidget(leadingIcon, fgColor));
        if (text != null) {
          children.add(const SizedBox(width: 8));
        }
      }

      if (text != null) {
        children.add(
          Flexible(
            child: Text(
              text!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: _fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                height: 1.0,
              ),
            ),
          ),
        );
      }

      if (trailingText != null) {
        children.add(const SizedBox(width: 8));
        children.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: fgColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trailingText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: _fontSize - 2,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ),
        );
      }

      if (trailingIcon != null) {
        children.add(const SizedBox(width: 8));
        children.add(_buildIconWidget(trailingIcon, fgColor));
      }

      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      );
    }

    Widget buttonBody = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: _height,
      width:
          customWidth ??
          (isCircle ? _height : (isFullWidth ? double.infinity : null)),
      padding: _padding,
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: _resolvedBorderRadius,
        border: border,
        boxShadow: effectiveDisabled ? null : shadows,
      ),
      child: Center(
        widthFactor: isFullWidth ? null : 1.0,
        heightFactor: 1.0,
        child: content,
      ),
    );

    // Specular highlight sheen overlay for primary bold gradient button
    if (variant == AmanahButtonVariant.primary && !effectiveDisabled) {
      buttonBody = Stack(
        children: <Widget>[
          buttonBody,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _height * 0.44,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: _resolvedBorderRadius.topLeft,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.28),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      enabled: !effectiveDisabled,
      label: semanticsLabel ?? text,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveDisabled ? null : _handleTap,
          borderRadius: _resolvedBorderRadius,
          splashColor: fgColor.withValues(alpha: 0.12),
          highlightColor: fgColor.withValues(alpha: 0.08),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AmanahComponentSize.minTouchTarget,
            ),
            child: buttonBody,
          ),
        ),
      ),
    );
  }
}

enum AmanahActionRowAxis { horizontal, vertical }

class AmanahActionRow extends StatelessWidget {
  const AmanahActionRow({
    required this.primary,
    super.key,
    this.secondary,
    this.axis = AmanahActionRowAxis.horizontal,
    this.primaryFlex = 2,
    this.secondaryFlex = 1,
    this.spacing = AmanahSpacing.md,
  });

  final Widget primary;
  final Widget? secondary;
  final AmanahActionRowAxis axis;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (secondary == null) {
      return primary;
    }

    if (axis == AmanahActionRowAxis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          primary,
          SizedBox(height: spacing),
          secondary!,
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(flex: secondaryFlex, child: secondary!),
        SizedBox(width: spacing),
        Expanded(flex: primaryFlex, child: primary),
      ],
    );
  }
}
