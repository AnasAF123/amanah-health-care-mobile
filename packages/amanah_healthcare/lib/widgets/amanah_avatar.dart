import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/amanah_asset_paths.dart';
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
    this.shape = BoxShape.circle,
    this.borderRadius,
    super.key,
  });

  /// Factory constructor for staff/doctor avatars with squircle/rounded rectangle styling
  factory AmanahAvatar.staff({
    String? avatarUrl,
    required String name,
    double size = 42.0,
    VoidCallback? onTap,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Color? backgroundColor,
    Color? initialsColor,
    String? semanticsLabel,
    Key? key,
  }) {
    final String cleanInitials = UserAvatar.extractInitials(name);
    final bool hasUrl = avatarUrl != null && avatarUrl.trim().isNotEmpty;
    return AmanahAvatar(
      key: key,
      avatar: UserAvatar(
        url: hasUrl ? avatarUrl.trim() : '',
        initials: cleanInitials,
        type: hasUrl ? 'custom' : 'initials',
        hasCustomAvatar: hasUrl,
      ),
      radius: size / 2,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(AmanahRadius.md),
      border: border,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      initialsColor: initialsColor,
      semanticsLabel: semanticsLabel ?? name,
      onTap: onTap,
    );
  }

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
  final BoxShape shape;
  final BorderRadius? borderRadius;

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

    final BorderRadius effectiveBorderRadius =
        borderRadius ??
        (shape == BoxShape.circle
            ? BorderRadius.circular(radius)
            : BorderRadius.circular(AmanahRadius.md));

    if (avatar.type == 'initials' || avatar.url.isEmpty) {
      avatarContent = _buildDefaultAvatarWidget(effectiveBorderRadius);
    } else {
      final String fullUrl = _resolvedFullUrl;
      avatarContent = SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: _clipContent(
          Image.network(
            fullUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
            loadingBuilder: (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
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
            errorBuilder: (BuildContext ctx, Object error, StackTrace? stackTrace) {
              return _buildDefaultAvatarWidget(effectiveBorderRadius);
            },
          ),
          effectiveBorderRadius,
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
              shape: shape,
              borderRadius: shape == BoxShape.rectangle ? effectiveBorderRadius : null,
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
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? effectiveBorderRadius : null,
          border: border,
          boxShadow: boxShadow,
        ),
        child: _clipContent(avatarContent, effectiveBorderRadius),
      );
    }

    if (semanticsLabel != null) {
      decorated = Semantics(label: semanticsLabel, image: true, child: decorated);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: decorated);
    }

    return decorated;
  }

  Widget _clipContent(Widget child, BorderRadius effectiveBorderRadius) {
    if (shape == BoxShape.circle) {
      return ClipOval(child: child);
    }
    return ClipRRect(borderRadius: effectiveBorderRadius, child: child);
  }

  Widget _buildDefaultAvatarWidget(BorderRadius effectiveBorderRadius) {
    final Widget image = Image.asset(
      AmanahAssetPaths.defaultAvatar,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      filterQuality: FilterQuality.high,
    );

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: _clipContent(image, effectiveBorderRadius),
    );
  }
}
