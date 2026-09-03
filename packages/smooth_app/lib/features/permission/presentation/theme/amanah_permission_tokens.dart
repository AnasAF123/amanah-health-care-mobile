// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';

/// Permission feature compatibility tokens.
///
/// New code should prefer AmanahThemeTokens directly. This wrapper keeps the
/// existing permission widgets stable while resolving status colors from the
/// shared Amanah design-system vocabulary.
abstract final class AmanahPermissionTokens {
  static Color getStatusBg(
    AmanahPermissionStatus status, {
    required bool dark,
  }) {
    final AmanahTone tone = _statusTone(status, dark: dark);
    return tone.surface;
  }

  static Color getStatusText(
    AmanahPermissionStatus status, {
    required bool dark,
  }) {
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
  static const Color cardBorderLight = AmanahColorTokens.neutral100;
  static const Color cardBorderDark = Color(0x1AFFFFFF);
  static const Color innerStitchBgLight = Color(0x66F8FAFC);
  static const Color innerStitchBgDark = Color(0x0AFFFFFF);
  static const Color dashedStrokeLight = Color(0xE6E2E8F0);
  static const Color dashedStrokeDark = Color(0x26FFFFFF);
  static const Color textTitleLight = AmanahColorTokens.neutral900;
  static const Color textTitleDark = Colors.white;
  static const Color textMutedLight = AmanahColorTokens.neutral500;
  static const Color textMutedDark = AmanahColorTokens.neutral400;
  static const Color textDetailBodyLight = Color(0xFF314158);
  static const Color textDetailBodyDark = Color(0xFFE2E8F0);
}
