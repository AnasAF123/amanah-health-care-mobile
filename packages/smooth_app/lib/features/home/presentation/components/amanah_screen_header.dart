import 'dart:ui';

import 'package:flutter/material.dart';

class AmanahScreenHeader extends StatelessWidget implements PreferredSizeWidget {
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
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color defaultBg = dark
        ? const Color(0xFF0A0E1A).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.85);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: backgroundColor ?? defaultBg,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // 1. Leading / Start (Back Button or Spacer)
              Align(
                alignment: Alignment.centerLeft,
                child: onBack != null
                    ? Semantics(
                        button: true,
                        label: 'Kembali',
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onBack,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 22,
                                color: dark
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: 40, height: 40),
              ),

              // 2. Absolute Optical Center (Title + Subtitle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
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
                        letterSpacing: -0.3,
                        color: dark ? Colors.white : const Color(0xFF0F172A),
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
                            letterSpacing: -0.2,
                            color: dark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
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
                child: rightAction ?? const SizedBox(width: 40, height: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
