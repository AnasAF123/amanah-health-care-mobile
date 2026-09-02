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
    final AmanahTone tone = _statusTone(status);
    if (dark) {
      return tone.dark.withValues(
        alpha: status == AmanahPermissionStatus.dibatalkan ? 0.24 : 0.44,
      );
    }
    return tone.surface;
  }

  static Color getStatusText(
    AmanahPermissionStatus status, {
    required bool dark,
  }) {
    final AmanahTone tone = _statusTone(status);
    if (dark) {
      return status == AmanahPermissionStatus.dibatalkan
          ? AmanahColorTokens.neutral300
          : tone.light;
    }
    return tone.onSurface;
  }

  static AmanahTone _statusTone(AmanahPermissionStatus status) {
    switch (status) {
      case AmanahPermissionStatus.menunggu:
        return AmanahThemeTokens.status(AmanahStatusTone.warning);
      case AmanahPermissionStatus.disetujui:
        return AmanahThemeTokens.status(AmanahStatusTone.success);
      case AmanahPermissionStatus.ditolak:
        return AmanahThemeTokens.status(AmanahStatusTone.danger);
      case AmanahPermissionStatus.dibatalkan:
        return AmanahThemeTokens.status(AmanahStatusTone.neutral);
    }
  }

  static const Color cardWrapperLight = AmanahColorTokens.surfaceLight;
  static const Color cardWrapperDark = Color(0xFF0F1524);
  static const Color cardBorderLight = AmanahColorTokens.neutral100;
  static const Color cardBorderDark = Color(0x0DFFFFFF);
  static const Color innerStitchBgLight = Color(0x66F8FAFC);
  static const Color innerStitchBgDark = Color(0x05FFFFFF);
  static const Color dashedStrokeLight = Color(0xE6E2E8F0);
  static const Color dashedStrokeDark = Color(0x26FFFFFF);
  static const Color textTitleLight = AmanahColorTokens.neutral900;
  static const Color textTitleDark = Colors.white;
  static const Color textMutedLight = AmanahColorTokens.neutral400;
  static const Color textMutedDark = AmanahColorTokens.neutral400;
  static const Color textDetailBodyLight = Color(0xFF314158);
  static const Color textDetailBodyDark = Color(0xFFE5E5E5);
}
