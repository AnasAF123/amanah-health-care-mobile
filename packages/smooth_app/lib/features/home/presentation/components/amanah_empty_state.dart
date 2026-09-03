import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_isometric_empty_box.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Layout style variant for [AmanahEmptyState].
enum AmanahEmptyStateVariant {
  /// Full-viewport or expanded list area with transparent background.
  viewport,

  /// Boxed card container with surface background and subtle border.
  card,

  /// Compact inline variant for small cards, drawers, or dialogs.
  compact,
}

/// Visual illustration mode for [AmanahEmptyState].
enum AmanahEmptyStateIllustration {
  /// 3D Isometric Empty Box canvas animation (from emptystate.html).
  isometricBox,

  /// Badge container with vector icon.
  badge,

  /// Custom widget illustration.
  custom,
}

/// Icon container shape for [AmanahEmptyState].
enum AmanahEmptyStateIconShape {
  /// Rounded container (squircle / 24dp rounded corners).
  squircle,

  /// Full circular container.
  circle,
}

/// Color tone for the icon badge in [AmanahEmptyState].
enum AmanahEmptyStateTone { neutral, brand, warning, danger, success }

/// Layout mode for actions when both primary and secondary actions are present.
enum AmanahEmptyStateActionLayout {
  /// Automatically decides between Row (viewport) or Column (card full-width).
  auto,

  /// Forces horizontal side-by-side buttons.
  horizontal,

  /// Forces vertical stacked buttons.
  vertical,
}

/// Master Empty State component for the Amanah mobile application.
///
/// Complies with Android native design patterns and the Amanah design system:
/// - 3D Isometric Empty Box canvas animation matching emptystate.html POC 1:1
/// - Distinctive visual badge fallback (squircle or circular with subtle tint & border)
/// - Bold, clear headline and supportive explanatory message
/// - Flexible single or dual action buttons powered by [AmanahButton]
/// - Dark/Light mode support with semantic tokens from [AmanahThemeTokens]
class AmanahEmptyState extends StatelessWidget {
  const AmanahEmptyState({
    required this.title,
    super.key,
    this.message,
    this.icon,
    this.customIcon,
    this.illustration = AmanahEmptyStateIllustration.badge,
    this.variant = AmanahEmptyStateVariant.viewport,
    this.iconShape = AmanahEmptyStateIconShape.squircle,
    this.tone = AmanahEmptyStateTone.neutral,
    this.boxSize = 220.0,
    this.showAnimationControls = false,
    this.actionText,
    this.onAction,
    this.actionLeadingIcon,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.secondaryActionLeadingIcon,
    this.actionLayout = AmanahEmptyStateActionLayout.auto,
    this.customAction,
    this.padding,
    this.maxWidth = 300,
    this.iconSize,
    this.iconContainerSize,
  });

  /// Master factory for 3D Isometric Empty Box empty states (1:1 from emptystate.html).
  const AmanahEmptyState.box({
    required String title,
    Key? key,
    String? message,
    double boxSize = 220.0,
    bool showAnimationControls = false,
    AmanahEmptyStateVariant variant = AmanahEmptyStateVariant.card,
    String? actionText,
    VoidCallback? onAction,
    IconData? actionLeadingIcon,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    IconData? secondaryActionLeadingIcon,
    AmanahEmptyStateActionLayout actionLayout =
        AmanahEmptyStateActionLayout.auto,
    Widget? customAction,
    EdgeInsetsGeometry? padding,
    double? maxWidth = 320,
  }) : this(
         key: key,
         title: title,
         message: message,
         illustration: AmanahEmptyStateIllustration.isometricBox,
         boxSize: boxSize,
         showAnimationControls: showAnimationControls,
         variant: variant,
         actionText: actionText,
         onAction: onAction,
         actionLeadingIcon: actionLeadingIcon,
         secondaryActionText: secondaryActionText,
         onSecondaryAction: onSecondaryAction,
         secondaryActionLeadingIcon: secondaryActionLeadingIcon,
         actionLayout: actionLayout,
         customAction: customAction,
         padding: padding,
         maxWidth: maxWidth,
       );

  /// Convenient factory for full viewport / expanded list empty states.
  const AmanahEmptyState.viewport({
    required String title,
    Key? key,
    String? message,
    IconData? icon,
    Widget? customIcon,
    AmanahEmptyStateIllustration illustration =
        AmanahEmptyStateIllustration.badge,
    double boxSize = 220.0,
    AmanahEmptyStateIconShape iconShape = AmanahEmptyStateIconShape.squircle,
    AmanahEmptyStateTone tone = AmanahEmptyStateTone.neutral,
    String? actionText,
    VoidCallback? onAction,
    IconData? actionLeadingIcon,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    IconData? secondaryActionLeadingIcon,
    AmanahEmptyStateActionLayout actionLayout =
        AmanahEmptyStateActionLayout.auto,
    Widget? customAction,
    EdgeInsetsGeometry? padding,
    double? maxWidth = 280,
  }) : this(
         key: key,
         title: title,
         message: message,
         icon: icon,
         customIcon: customIcon,
         illustration: illustration,
         boxSize: boxSize,
         variant: AmanahEmptyStateVariant.viewport,
         iconShape: iconShape,
         tone: tone,
         actionText: actionText,
         onAction: onAction,
         actionLeadingIcon: actionLeadingIcon,
         secondaryActionText: secondaryActionText,
         onSecondaryAction: onSecondaryAction,
         secondaryActionLeadingIcon: secondaryActionLeadingIcon,
         actionLayout: actionLayout,
         customAction: customAction,
         padding: padding,
         maxWidth: maxWidth,
       );

  /// Convenient factory for boxed card empty states (e.g. inside scroll views).
  const AmanahEmptyState.card({
    required String title,
    Key? key,
    String? message,
    IconData? icon,
    Widget? customIcon,
    AmanahEmptyStateIllustration illustration =
        AmanahEmptyStateIllustration.badge,
    double boxSize = 220.0,
    AmanahEmptyStateIconShape iconShape = AmanahEmptyStateIconShape.circle,
    AmanahEmptyStateTone tone = AmanahEmptyStateTone.neutral,
    String? actionText,
    VoidCallback? onAction,
    IconData? actionLeadingIcon,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    IconData? secondaryActionLeadingIcon,
    AmanahEmptyStateActionLayout actionLayout =
        AmanahEmptyStateActionLayout.auto,
    Widget? customAction,
    EdgeInsetsGeometry? padding,
    double? maxWidth = 300,
  }) : this(
         key: key,
         title: title,
         message: message,
         icon: icon,
         customIcon: customIcon,
         illustration: illustration,
         boxSize: boxSize,
         variant: AmanahEmptyStateVariant.card,
         iconShape: iconShape,
         tone: tone,
         actionText: actionText,
         onAction: onAction,
         actionLeadingIcon: actionLeadingIcon,
         secondaryActionText: secondaryActionText,
         onSecondaryAction: onSecondaryAction,
         secondaryActionLeadingIcon: secondaryActionLeadingIcon,
         actionLayout: actionLayout,
         customAction: customAction,
         padding: padding,
         maxWidth: maxWidth,
       );

  /// Convenient factory for compact empty state banners.
  const AmanahEmptyState.compact({
    required String title,
    Key? key,
    String? message,
    IconData? icon,
    Widget? customIcon,
    AmanahEmptyStateIconShape iconShape = AmanahEmptyStateIconShape.squircle,
    AmanahEmptyStateTone tone = AmanahEmptyStateTone.neutral,
    String? actionText,
    VoidCallback? onAction,
    IconData? actionLeadingIcon,
    Widget? customAction,
    EdgeInsetsGeometry? padding,
    double? maxWidth = 260,
  }) : this(
         key: key,
         title: title,
         message: message,
         icon: icon,
         customIcon: customIcon,
         illustration: AmanahEmptyStateIllustration.badge,
         variant: AmanahEmptyStateVariant.compact,
         iconShape: iconShape,
         tone: tone,
         actionText: actionText,
         onAction: onAction,
         actionLeadingIcon: actionLeadingIcon,
         actionLayout: AmanahEmptyStateActionLayout.auto,
         customAction: customAction,
         padding: padding,
         maxWidth: maxWidth,
       );

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? customIcon;
  final AmanahEmptyStateIllustration illustration;
  final AmanahEmptyStateVariant variant;
  final AmanahEmptyStateIconShape iconShape;
  final AmanahEmptyStateTone tone;
  final double boxSize;
  final bool showAnimationControls;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? actionLeadingIcon;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final IconData? secondaryActionLeadingIcon;
  final AmanahEmptyStateActionLayout actionLayout;
  final Widget? customAction;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final double? iconSize;
  final double? iconContainerSize;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);

    final Widget content = Semantics(
      container: true,
      label: message != null ? '$title. $message' : title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildIllustration(context, dark),
          SizedBox(height: _titleSpacing),
          _buildTitle(textColor),
          if (message != null && message!.isNotEmpty) ...<Widget>[
            SizedBox(height: _messageSpacing),
            _buildMessage(subtextColor),
          ],
          if (customAction != null ||
              actionText != null ||
              secondaryActionText != null) ...<Widget>[
            SizedBox(height: _actionSpacing),
            _buildActions(context, dark),
          ],
        ],
      ),
    );

    final EdgeInsetsGeometry resolvedPadding = padding ?? _defaultPadding;

    switch (variant) {
      case AmanahEmptyStateVariant.viewport:
        return Center(
          child: Padding(padding: resolvedPadding, child: content),
        );

      case AmanahEmptyStateVariant.card:
        return Container(
          width: double.infinity,
          padding: resolvedPadding,
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF1F5F9),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.20 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: content,
        );

      case AmanahEmptyStateVariant.compact:
        return Padding(padding: resolvedPadding, child: content);
    }
  }

  Widget _buildIllustration(BuildContext context, bool dark) {
    if (illustration == AmanahEmptyStateIllustration.isometricBox) {
      return AmanahIsometricEmptyBox(
        size: boxSize,
        showControls: showAnimationControls,
      );
    }

    if (customIcon != null) {
      return customIcon!;
    }

    return _buildIconBadge(context, dark);
  }

  Widget _buildIconBadge(BuildContext context, bool dark) {
    final double defaultContainerSize =
        variant == AmanahEmptyStateVariant.compact ? 48.0 : 64.0;
    final double defaultIconSize = variant == AmanahEmptyStateVariant.compact
        ? 22.0
        : 28.0;

    final double badgeSize = iconContainerSize ?? defaultContainerSize;
    final double resolvedIconSize = iconSize ?? defaultIconSize;

    final (Color bgColor, Color borderColor, Color iconColor) =
        _resolveToneColors(dark);

    final BorderRadius? borderRadius =
        iconShape == AmanahEmptyStateIconShape.squircle
        ? BorderRadius.circular(
            variant == AmanahEmptyStateVariant.compact ? 18.0 : 24.0,
          )
        : null;

    final BoxShape shape = iconShape == AmanahEmptyStateIconShape.circle
        ? BoxShape.circle
        : BoxShape.rectangle;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: shape,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: resolvedIconSize, color: iconColor)
            : const SizedBox.shrink(),
      ),
    );
  }

  (Color, Color, Color) _resolveToneColors(bool dark) {
    switch (tone) {
      case AmanahEmptyStateTone.neutral:
        return (
          dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0),
          dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        );
      case AmanahEmptyStateTone.brand:
        return (
          dark
              ? AmanahColorTokens.brand.withValues(alpha: 0.15)
              : const Color(0xFFEFF6FF),
          dark
              ? AmanahColorTokens.brand.withValues(alpha: 0.30)
              : const Color(0xFFBFDBFE),
          dark ? AmanahColorTokens.brandAccent : const Color(0xFF0A44FF),
        );
      case AmanahEmptyStateTone.warning:
        return (
          dark
              ? AmanahColorTokens.warning.withValues(alpha: 0.15)
              : AmanahColorTokens.warningSurface,
          dark
              ? AmanahColorTokens.warning.withValues(alpha: 0.30)
              : AmanahColorTokens.warningBorder,
          dark ? AmanahColorTokens.warning : AmanahColorTokens.warningDark,
        );
      case AmanahEmptyStateTone.danger:
        return (
          dark
              ? AmanahColorTokens.danger.withValues(alpha: 0.15)
              : AmanahColorTokens.dangerSurface,
          dark
              ? AmanahColorTokens.danger.withValues(alpha: 0.30)
              : AmanahColorTokens.dangerBorder,
          dark ? AmanahColorTokens.danger : AmanahColorTokens.dangerDark,
        );
      case AmanahEmptyStateTone.success:
        return (
          dark
              ? AmanahColorTokens.success.withValues(alpha: 0.15)
              : AmanahColorTokens.successSurface,
          dark
              ? AmanahColorTokens.success.withValues(alpha: 0.30)
              : AmanahColorTokens.successBorder,
          dark ? AmanahColorTokens.success : AmanahColorTokens.successDark,
        );
    }
  }

  Widget _buildTitle(Color textColor) {
    final double fontSize = switch (variant) {
      AmanahEmptyStateVariant.viewport => 16.0,
      AmanahEmptyStateVariant.card => 15.0,
      AmanahEmptyStateVariant.compact => 13.5,
    };

    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
    );
  }

  Widget _buildMessage(Color subtextColor) {
    final double fontSize = variant == AmanahEmptyStateVariant.compact
        ? 11.0
        : 12.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 280),
      child: Text(
        message!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: subtextColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool dark) {
    if (customAction != null) {
      return customAction!;
    }

    final String? pText = actionText;
    final VoidCallback? pAction = onAction;
    final String? sText = secondaryActionText;
    final VoidCallback? sAction = onSecondaryAction;

    final bool hasPrimary = pText != null && pAction != null;
    final bool hasSecondary = sText != null && sAction != null;

    if (!hasPrimary && !hasSecondary) {
      return const SizedBox.shrink();
    }

    final bool isVertical =
        actionLayout == AmanahEmptyStateActionLayout.vertical ||
        (actionLayout == AmanahEmptyStateActionLayout.auto &&
            variant == AmanahEmptyStateVariant.card);

    if (hasPrimary && hasSecondary) {
      if (isVertical) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AmanahButton.primary(
              text: pText,
              leadingIcon: actionLeadingIcon,
              isFullWidth: true,
              size: AmanahButtonSize.medium,
              onPressed: pAction,
            ),
            const SizedBox(height: 8),
            AmanahButton.ghost(
              text: sText,
              leadingIcon: secondaryActionLeadingIcon,
              isFullWidth: true,
              size: AmanahButtonSize.medium,
              customForegroundColor: dark
                  ? AmanahColorTokens.neutral200
                  : AmanahColorTokens.neutral700,
              onPressed: sAction,
            ),
          ],
        );
      } else {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: <Widget>[
            AmanahButton.outline(
              text: pText,
              leadingIcon: actionLeadingIcon,
              size: AmanahButtonSize.small,
              onPressed: pAction,
            ),
            AmanahButton.secondary(
              text: sText,
              leadingIcon: secondaryActionLeadingIcon,
              size: AmanahButtonSize.small,
              onPressed: sAction,
            ),
          ],
        );
      }
    }

    // Only primary action
    if (hasPrimary) {
      final bool fullWidth = variant == AmanahEmptyStateVariant.card;
      return fullWidth
          ? AmanahButton.primary(
              text: pText,
              leadingIcon: actionLeadingIcon,
              isFullWidth: true,
              size: AmanahButtonSize.medium,
              onPressed: pAction,
            )
          : AmanahButton.primary(
              text: pText,
              leadingIcon: actionLeadingIcon,
              size: AmanahButtonSize.medium,
              onPressed: pAction,
            );
    }

    // Only secondary action
    return AmanahButton.ghost(
      text: sText,
      leadingIcon: secondaryActionLeadingIcon,
      size: AmanahButtonSize.medium,
      customForegroundColor: dark
          ? AmanahColorTokens.neutral200
          : AmanahColorTokens.neutral700,
      onPressed: sAction,
    );
  }

  double get _titleSpacing => switch (variant) {
    AmanahEmptyStateVariant.viewport => 16.0,
    AmanahEmptyStateVariant.card => 14.0,
    AmanahEmptyStateVariant.compact => 10.0,
  };

  double get _messageSpacing => switch (variant) {
    AmanahEmptyStateVariant.viewport => 6.0,
    AmanahEmptyStateVariant.card => 5.0,
    AmanahEmptyStateVariant.compact => 4.0,
  };

  double get _actionSpacing => switch (variant) {
    AmanahEmptyStateVariant.viewport => 22.0,
    AmanahEmptyStateVariant.card => 18.0,
    AmanahEmptyStateVariant.compact => 14.0,
  };

  EdgeInsetsGeometry get _defaultPadding => switch (variant) {
    AmanahEmptyStateVariant.viewport => const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 32,
    ),
    AmanahEmptyStateVariant.card => const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 28,
    ),
    AmanahEmptyStateVariant.compact => const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 20,
    ),
  };
}
