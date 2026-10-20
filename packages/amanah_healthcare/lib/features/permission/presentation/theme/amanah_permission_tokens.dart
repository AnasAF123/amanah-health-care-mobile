// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';

/// Permission feature compatibility tokens.
///
/// New code should prefer AmanahThemeTokens directly. This wrapper keeps the
/// existing permission widgets stable while resolving status colors from the
/// shared Amanah design-system vocabulary.
abstract final class AmanahPermissionTokens {
  static Color getStatusBg(AmanahPermissionStatus status, {required bool dark}) {
    final AmanahTone tone = _statusTone(status, dark: dark);
    return tone.surface;
  }

  static Color getStatusText(AmanahPermissionStatus status, {required bool dark}) {
    final AmanahTone tone = _statusTone(status, dark: dark);
    return tone.onSurface;
  }

  static AmanahTone _statusTone(AmanahPermissionStatus status, {bool dark = false}) {
    switch (status) {
      case AmanahPermissionStatus.menunggu:
        return AmanahThemeTokens.status(AmanahStatusTone.warning, isDark: dark);
      case AmanahPermissionStatus.disetujui:
        return AmanahThemeTokens.status(AmanahStatusTone.success, isDark: dark);
      case AmanahPermissionStatus.ditolak:
        return AmanahThemeTokens.status(AmanahStatusTone.danger, isDark: dark);
      case AmanahPermissionStatus.dibatalkan:
        return AmanahThemeTokens.status(AmanahStatusTone.neutral, isDark: dark);
    }
  }

  static const Color cardWrapperLight = AmanahColorTokens.surfaceLight;
  static const Color cardWrapperDark = AmanahColorTokens.surfaceDark;
  static const Color cardBorderLight = AmanahColorTokens.neutral200;
  static final Color cardBorderDark = AmanahColorTokens.surfaceLight.withValues(alpha: 0.10);
  static const Color innerStitchBgLight = AmanahColorTokens.neutral50;
  static final Color innerStitchBgDark = AmanahColorTokens.surfaceLight.withValues(alpha: 0.04);
  static const Color dashedStrokeLight = AmanahColorTokens.neutral300;
  static final Color dashedStrokeDark = AmanahColorTokens.surfaceLight.withValues(alpha: 0.15);
  static const Color textTitleLight = AmanahColorTokens.neutral900;
  static const Color textTitleDark = AmanahColorTokens.surfaceLight;
  static const Color textMutedLight = AmanahColorTokens.neutral500;
  static const Color textMutedDark = AmanahColorTokens.neutral400;
  static const Color textDetailBodyLight = AmanahColorTokens.neutral700;
  static const Color textDetailBodyDark = AmanahColorTokens.neutral200;
}
