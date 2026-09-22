import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Universal Avatar Widget for Amanah Healthcare
/// Automatically handles custom WebP images, Google OAuth redirects, and clinical-grade SVG/Circle initials fallback.
class AmanahAvatar extends StatelessWidget {
  const AmanahAvatar({
    required this.avatar,
    this.baseUrl,
    this.radius = 24.0,
    this.onTap,
    this.border,
    this.boxShadow,
    this.backgroundColor,
    this.initialsColor,
    this.semanticsLabel,
    this.isLoading = false,
    super.key,
  });

  final UserAvatar avatar;
  final String? baseUrl;
  final double radius;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;
  final Color? initialsColor;
  final String? semanticsLabel;
  final bool isLoading;

  static String resolveDefaultBaseUrl() {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3001';
    }
    return 'http://localhost:3001';
  }

  String get _resolvedFullUrl {
    final String raw = avatar.directUrl != null && avatar.directUrl!.isNotEmpty
        ? avatar.directUrl!
        : avatar.url;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final String base = baseUrl ?? resolveDefaultBaseUrl();
    if (raw.startsWith('/')) {
      return '$base$raw';
    }
    return '$base/$raw';
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    final Color brandBg = backgroundColor ?? AmanahColorTokens.brand;
    final Color textColor = initialsColor ?? Colors.white;

    if (avatar.type == 'initials' || avatar.url.isEmpty) {
      avatarContent = _buildInitialsWidget(brandBg, textColor);
    } else {
      final String fullUrl = _resolvedFullUrl;
      avatarContent = SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: Image.network(
            fullUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            loadingBuilder: (
              BuildContext ctx,
              Widget child,
              ImageChunkEvent? loadingProgress,
            ) {
              if (loadingProgress == null) return child;
              return Container(
                color: AmanahColorTokens.neutral100,
                alignment: Alignment.center,
                child: SizedBox(
                  width: radius * 0.7,
                  height: radius * 0.7,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (
              BuildContext ctx,
              Object error,
              StackTrace? stackTrace,
            ) {
              return _buildInitialsWidget(brandBg, textColor);
            },
          ),
        ),
      );
    }

    if (isLoading) {
      avatarContent = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          avatarContent,
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.45),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: radius * 0.75,
              height: radius * 0.75,
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      );
    }

    Widget decorated = avatarContent;
    if (border != null || boxShadow != null) {
      decorated = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
          boxShadow: boxShadow,
        ),
        child: ClipOval(child: avatarContent),
      );
    }

    if (semanticsLabel != null) {
      decorated = Semantics(
        label: semanticsLabel,
        image: true,
        child: decorated,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: decorated,
      );
    }

    return decorated;
  }

  Widget _buildInitialsWidget(Color brandBg, Color textColor) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: brandBg,
      child: Text(
        avatar.initials.isNotEmpty ? avatar.initials : 'AH',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.75,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
