import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

enum AmanahScreenHeaderLeading { auto, back, none }

enum AmanahScreenHeaderTitleAlignment { center, start }

class AmanahScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const AmanahScreenHeader({
    this.title,
    super.key,
    this.subtitle,
    this.onBack,
    this.leading = AmanahScreenHeaderLeading.auto,
    this.leadingAction,
    this.trailing,
    this.rightAction,
    this.backgroundColor,
    this.titleWidget,
    this.titleAlignment = AmanahScreenHeaderTitleAlignment.center,
    this.showDivider = false,
    this.includeTopSafeArea = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AmanahSpacing.lg,
    ),
  });

  /// Variant: Standard Centered Title Header with back button
  const AmanahScreenHeader.standard({
    required String title,
    Key? key,
    String? subtitle,
    VoidCallback? onBack,
    Widget? trailing,
    bool showDivider = false,
  }) : this(
         key: key,
         title: title,
         subtitle: subtitle,
         onBack: onBack,
         leading: AmanahScreenHeaderLeading.back,
         trailing: trailing,
         showDivider: showDivider,
         titleAlignment: AmanahScreenHeaderTitleAlignment.center,
       );

  /// Variant: Start-Aligned Title Header with leading and trailing actions
  const AmanahScreenHeader.startAligned({
    required String title,
    Key? key,
    String? subtitle,
    VoidCallback? onBack,
    AmanahScreenHeaderLeading leading = AmanahScreenHeaderLeading.auto,
    Widget? leadingAction,
    Widget? trailing,
    bool showDivider = false,
  }) : this(
         key: key,
         title: title,
         subtitle: subtitle,
         onBack: onBack,
         leading: leading,
         leadingAction: leadingAction,
         trailing: trailing,
         showDivider: showDivider,
         titleAlignment: AmanahScreenHeaderTitleAlignment.start,
       );

  /// Variant: Action-Only Header with no title (e.g. Back on left, menu on right)
  const AmanahScreenHeader.actionOnly({
    Key? key,
    VoidCallback? onBack,
    Widget? leadingAction,
    Widget? trailing,
    Color? backgroundColor,
  }) : this(
         key: key,
         onBack: onBack,
         leadingAction: leadingAction,
         trailing: trailing,
         backgroundColor: backgroundColor,
       );

  final String? title;
  final String? subtitle;
  final VoidCallback? onBack;
  final AmanahScreenHeaderLeading leading;
  final Widget? leadingAction;
  final Widget? trailing;
  final Widget? rightAction;
  final Color? backgroundColor;
  final Widget? titleWidget;
  final AmanahScreenHeaderTitleAlignment titleAlignment;
  final bool showDivider;
  final bool includeTopSafeArea;
  final EdgeInsetsGeometry contentPadding;

  @override
  Size get preferredSize =>
      const Size.fromHeight(AmanahComponentSize.topAppBar);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color defaultBg = dark
        ? AmanahColorTokens.canvasDark.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.85);

    final Widget header = SizedBox(
      width: double.infinity,
      height: AmanahComponentSize.topAppBar,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBg,
          border: showDivider
              ? Border(
                  bottom: BorderSide(color: AmanahThemeTokens.outline(context)),
                )
              : null,
        ),
        child: Padding(
          padding: contentPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 1. Leading Action Slot (Far Left)
              _buildLeadingSlot(
                context,
                reserveEmptySlot:
                    titleAlignment == AmanahScreenHeaderTitleAlignment.center,
              ),

              // 2. Title & Subtitle Block (Centered or Start-aligned in remaining space)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AmanahSpacing.sm,
                  ),
                  child: _buildTitleBlock(
                    context,
                    titleAlignment == AmanahScreenHeaderTitleAlignment.start
                        ? TextAlign.start
                        : TextAlign.center,
                  ),
                ),
              ),

              // 3. Trailing Action Slot (Far Right, e.g. more_vert, add, icons)
              _buildTrailingSlot(
                context,
                reserveEmptySlot:
                    titleAlignment == AmanahScreenHeaderTitleAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: SafeArea(top: includeTopSafeArea, bottom: false, child: header),
      ),
    );
  }

  Widget _buildTitleBlock(BuildContext context, TextAlign textAlign) {
    if (titleWidget != null) {
      return titleWidget!;
    }

    final String? resolvedTitle = title;
    if (resolvedTitle == null || resolvedTitle.isEmpty) {
      return const SizedBox.shrink();
    }

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          resolvedTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AmanahThemeTokens.textPrimary(context),
            height: 1.2,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AmanahSpacing.xxs),
            child: Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: textAlign,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: AmanahThemeTokens.textSecondary(context),
                height: 1.1,
              ),
            ),
          ),
      ],
    );

    if (textAlign == TextAlign.center) {
      return Center(child: content);
    }
    return content;
  }

  Widget _buildLeadingSlot(
    BuildContext context, {
    required bool reserveEmptySlot,
  }) {
    if (leadingAction != null) {
      return _AmanahHeaderSlot(child: leadingAction);
    }

    if (_shouldShowLeading(context)) {
      return AmanahScreenHeaderIconAction(
        icon: Icons.arrow_back_rounded,
        semanticsLabel: 'Kembali',
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      );
    }

    return reserveEmptySlot
        ? const SizedBox.square(dimension: AmanahComponentSize.iconButton)
        : const SizedBox.shrink();
  }

  Widget _buildTrailingSlot(
    BuildContext context, {
    required bool reserveEmptySlot,
  }) {
    final Widget? resolvedTrailing = trailing ?? rightAction;
    if (resolvedTrailing == null) {
      return reserveEmptySlot
          ? const SizedBox.square(dimension: AmanahComponentSize.iconButton)
          : const SizedBox.shrink();
    }
    return _AmanahHeaderSlot(child: resolvedTrailing);
  }

  bool _shouldShowLeading(BuildContext context) {
    return switch (leading) {
      AmanahScreenHeaderLeading.none => false,
      AmanahScreenHeaderLeading.back => true,
      AmanahScreenHeaderLeading.auto =>
        onBack != null || Navigator.canPop(context),
    };
  }
}

class AmanahScreenHeaderIconAction extends StatelessWidget {
  const AmanahScreenHeaderIconAction({
    required this.icon,
    required this.onPressed,
    required this.semanticsLabel,
    super.key,
    this.foregroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticsLabel;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return AmanahButton.icon(
      icon: icon,
      customSize: AmanahComponentSize.iconButton,
      customBackgroundColor: Colors.transparent,
      customBorder: Border.all(color: Colors.transparent),
      customForegroundColor:
          foregroundColor ?? AmanahThemeTokens.textSecondary(context),
      semanticsLabel: semanticsLabel,
      onPressed: onPressed,
    );
  }
}

class _AmanahHeaderSlot extends StatelessWidget {
  const _AmanahHeaderSlot({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: AmanahComponentSize.iconButton,
        minHeight: AmanahComponentSize.iconButton,
        maxHeight: AmanahComponentSize.iconButton,
      ),
      child: Center(child: child),
    );
  }
}
