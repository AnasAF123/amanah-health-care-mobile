import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahScreenHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const AmanahScreenHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.onBack,
    this.rightAction,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? rightAction;
  final Color? backgroundColor;

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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          height: AmanahComponentSize.topAppBar,
          padding: const EdgeInsets.symmetric(horizontal: AmanahSpacing.lg),
          color: backgroundColor ?? defaultBg,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 1. Leading / Start (Back Button or Spacer)
              Align(
                alignment: Alignment.centerLeft,
                child: (onBack != null || Navigator.canPop(context))
                    ? Semantics(
                        button: true,
                        label: 'Kembali',
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap:
                                onBack ??
                                () => Navigator.of(context).maybePop(),
                            child: SizedBox.square(
                              dimension: AmanahComponentSize.iconButton,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 22,
                                color: AmanahThemeTokens.textSecondary(context),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.square(
                        dimension: AmanahComponentSize.iconButton,
                      ),
              ),

              // 2. Absolute Optical Center (Title + Subtitle)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AmanahComponentSize.iconButton,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
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
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
                ),
              ),

              // 3. Trailing / End Action
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox.square(
                  dimension: AmanahComponentSize.iconButton,
                  child: rightAction == null
                      ? const SizedBox.shrink()
                      : Center(child: rightAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
