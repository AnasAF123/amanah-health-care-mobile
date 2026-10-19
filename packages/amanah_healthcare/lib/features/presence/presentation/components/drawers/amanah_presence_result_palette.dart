import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';

/// Contextual color, typography, and iconography scheme for presence outcome results.
class PresenceResultPalette {
  const PresenceResultPalette({
    required this.surface,
    required this.mutedSurface,
    required this.title,
    required this.subtitle,
    required this.metaText,
    required this.border,
    required this.handle,
    required this.primary,
    required this.primaryText,
    required this.primarySoft,
    required this.onPrimary,
    required this.iconData,
    required this.showConfetti,
    required this.badgeTheme,
  });

  final Color surface;
  final Color mutedSurface;
  final Color title;
  final Color subtitle;
  final Color metaText;
  final Color border;
  final Color handle;
  final Color primary;
  final Color primaryText;
  final Color primarySoft;
  final Color onPrimary;
  final IconData iconData;
  final bool showConfetti;
  final BadgeStageTheme badgeTheme;

  /// Resolves the visual scheme based on theme brightness and [PresenceStatusType].
  static PresenceResultPalette resolve({
    required ThemeData theme,
    required PresenceStatusType type,
  }) {
    final bool dark = theme.brightness == Brightness.dark;
    final Color surface =
        dark ? theme.colorScheme.surface : AmanahColorTokens.surfaceLight;

    Color primary;
    Color primarySoft;
    IconData iconData;
    bool showConfetti = false;
    BadgeStageTheme badgeTheme;

    switch (type) {
      case PresenceStatusType.successCheckIn:
        primary = dark
            ? const Color(0xFF0284C7) // btnCrispBlueDarkGradient base
            : AmanahColorTokens.brand; // btnCrispBlueGradient base
        primarySoft = dark
            ? primary.withValues(alpha: 0.16)
            : AmanahColorTokens.brandSurface;
        iconData = Icons.check_rounded;
        showConfetti = true;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF082F49).withValues(alpha: 0.55) : const Color(0xFFE8F2FE),
          auraEdge: dark ? const Color(0xFF061826) : const Color(0xFFD6E7FC),
          badgeShadow: dark ? const Color(0x5C0284C7) : const Color(0x5C0D66E9),
          // Matches btnCrispBlueDarkGradient in dark mode and btnCrispBlueGradient in light mode
          outerTop: dark ? const Color(0xFF38BDF8) : const Color(0xFF3B8AEB),
          outerBottom: dark ? const Color(0xFF0284C7) : const Color(0xFF0D66E9),
          innerRecess: dark ? const Color(0xFF0369A1) : const Color(0xFF0A44FF),
          innerRim: dark ? const Color(0xFF7DD3FC) : const Color(0xFF60A5FA),
          ribbonTop: dark ? const Color(0xFFE0F2FE) : const Color(0xFFEFF6FF),
          ribbonBottom: dark ? const Color(0xFF38BDF8) : const Color(0xFF93C5FD),
          glyphColor: dark ? const Color(0xFF082F49) : const Color(0xFF0A38B8),
        );
        break;

      case PresenceStatusType.successCheckOut:
        primary = dark
            ? const Color(0xFF0284C7)
            : AmanahColorTokens.brandNavyBold;
        primarySoft = dark
            ? primary.withValues(alpha: 0.16)
            : AmanahColorTokens.brandSurface;
        iconData = Icons.logout_rounded;
        showConfetti = true;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF082F49).withValues(alpha: 0.55) : const Color(0xFFE5F1FC),
          auraEdge: dark ? const Color(0xFF061826) : const Color(0xFFCCE4F9),
          badgeShadow: dark ? const Color(0x5C0284C7) : const Color(0x5C1E40AF),
          outerTop: dark ? const Color(0xFF38BDF8) : const Color(0xFF38BDF8),
          outerBottom: dark ? const Color(0xFF0284C7) : const Color(0xFF1E40AF),
          innerRecess: dark ? const Color(0xFF0369A1) : const Color(0xFF1E3A8A),
          innerRim: dark ? const Color(0xFF7DD3FC) : const Color(0xFF38BDF8),
          ribbonTop: dark ? const Color(0xFFE0F2FE) : const Color(0xFFE0F2FE),
          ribbonBottom: dark ? const Color(0xFF38BDF8) : const Color(0xFF7DD3FC),
          glyphColor: dark ? const Color(0xFF082F49) : const Color(0xFF0C4A6E),
        );
        break;

      case PresenceStatusType.conflictAlreadyCheckedIn:
      case PresenceStatusType.conflictAlreadyCheckedOut:
        primary = dark
            ? AmanahColorTokens.warningLight
            : AmanahColorTokens.warning;
        primarySoft = dark
            ? primary.withValues(alpha: 0.18)
            : AmanahColorTokens.amberSurfaceSoft;
        iconData = Icons.history_toggle_off_rounded;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF33240D) : const Color(0xFFFFF4E0),
          auraEdge: dark ? const Color(0xFF211606) : const Color(0xFFFDE7BE),
          badgeShadow: const Color(0x5CF5A623),
          outerTop: const Color(0xFFFFCC66),
          outerBottom: const Color(0xFFF5981C),
          innerRecess: const Color(0xFFDE820E),
          innerRim: const Color(0xFFFCB84E),
          ribbonTop: const Color(0xFFFFF3DB),
          ribbonBottom: const Color(0xFFFAB652),
          glyphColor: const Color(0xFFB36204),
        );
        break;

      case PresenceStatusType.outOfSchedule:
        primary = dark
            ? const Color(0xFFA78BFA) // Violet light
            : const Color(0xFF7C3AED); // Deep Violet
        primarySoft = dark
            ? primary.withValues(alpha: 0.18)
            : const Color(0xFFF3E8FF);
        iconData = Icons.event_busy_rounded;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF231638) : const Color(0xFFF5EEFD),
          auraEdge: dark ? const Color(0xFF170E25) : const Color(0xFFE9DCF8),
          badgeShadow: const Color(0x5C7C3AED),
          outerTop: const Color(0xFFC084FC),
          outerBottom: const Color(0xFF7C3AED),
          innerRecess: const Color(0xFF6D28D9),
          innerRim: const Color(0xFFA855F7),
          ribbonTop: const Color(0xFFF3E8FF),
          ribbonBottom: const Color(0xFFC084FC),
          glyphColor: const Color(0xFF5B21B6),
        );
        break;

      case PresenceStatusType.onOfficialLeave:
        primary = dark
            ? const Color(0xFF2DD4BF) // Teal light
            : const Color(0xFF0D9488); // Deep Teal
        primarySoft = dark
            ? primary.withValues(alpha: 0.18)
            : const Color(0xFFCCFBF1);
        iconData = Icons.beach_access_rounded;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF112638) : const Color(0xFFE6F4FE),
          auraEdge: dark ? const Color(0xFF0B1925) : const Color(0xFFCDE8FD),
          badgeShadow: const Color(0x5C38A8FA),
          outerTop: const Color(0xFF7ACBFF),
          outerBottom: const Color(0xFF2A98F5),
          innerRecess: const Color(0xFF1A81DB),
          innerRim: const Color(0xFF60B8FC),
          ribbonTop: const Color(0xFFE0F4FF),
          ribbonBottom: const Color(0xFF6CBFFC),
          glyphColor: const Color(0xFF0F62AD),
        );
        break;

      case PresenceStatusType.invalidOrExpiredToken:
        primary = dark
            ? AmanahColorTokens.roseLight
            : const Color(0xFFE11D48); // Rose 600
        primarySoft = dark
            ? primary.withValues(alpha: 0.18)
            : const Color(0xFFFFE4E6);
        iconData = Icons.qr_code_2_rounded;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF351216) : const Color(0xFFFEE9EA),
          auraEdge: dark ? const Color(0xFF220A0D) : const Color(0xFFFCD5D8),
          badgeShadow: const Color(0x5CF44C5C),
          outerTop: const Color(0xFFFF8A94),
          outerBottom: const Color(0xFFEF4454),
          innerRecess: const Color(0xFFD63142),
          innerRim: const Color(0xFFFA7380),
          ribbonTop: const Color(0xFFFFE4E7),
          ribbonBottom: const Color(0xFFF87683),
          glyphColor: const Color(0xFFB01E2E),
        );
        break;

      case PresenceStatusType.genericError:
        primary = dark
            ? const Color(0xFFF87171) // Red light
            : AmanahColorTokens.danger;
        primarySoft = dark
            ? primary.withValues(alpha: 0.18)
            : AmanahColorTokens.dangerSurface;
        iconData = Icons.error_outline_rounded;
        badgeTheme = BadgeStageTheme(
          auraMid: dark ? const Color(0xFF351216) : const Color(0xFFFEE9EA),
          auraEdge: dark ? const Color(0xFF220A0D) : const Color(0xFFFCD5D8),
          badgeShadow: const Color(0x5CF44C5C),
          outerTop: const Color(0xFFFF8A94),
          outerBottom: const Color(0xFFEF4454),
          innerRecess: const Color(0xFFD63142),
          innerRim: const Color(0xFFFA7380),
          ribbonTop: const Color(0xFFFFE4E7),
          ribbonBottom: const Color(0xFFF87683),
          glyphColor: const Color(0xFFB01E2E),
        );
        break;
    }

    return PresenceResultPalette(
      surface: surface,
      mutedSurface: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.48),
      title: dark ? theme.colorScheme.onSurface : AmanahColorTokens.heading,
      subtitle: dark
          ? theme.colorScheme.onSurfaceVariant
          : AmanahColorTokens.muted,
      metaText: dark
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      border: dark
          ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
          : primary.withValues(alpha: 0.20),
      handle: dark
          ? theme.colorScheme.onSurface.withValues(alpha: 0.20)
          : theme.colorScheme.outlineVariant,
      primary: primary,
      primaryText: primary,
      primarySoft: primarySoft,
      onPrimary: AmanahColorTokens.surfaceLight,
      iconData: iconData,
      showConfetti: showConfetti,
      badgeTheme: badgeTheme,
    );
  }
}

/// Color tokens tailored specifically for 3D hexagon badge and ambient aura headers.
class BadgeStageTheme {
  const BadgeStageTheme({
    required this.auraMid,
    required this.auraEdge,
    required this.badgeShadow,
    required this.outerTop,
    required this.outerBottom,
    required this.innerRecess,
    required this.innerRim,
    required this.ribbonTop,
    required this.ribbonBottom,
    required this.glyphColor,
  });

  final Color auraMid;
  final Color auraEdge;
  final Color badgeShadow;
  final Color outerTop;
  final Color outerBottom;
  final Color innerRecess;
  final Color innerRim;
  final Color ribbonTop;
  final Color ribbonBottom;
  final Color glyphColor;
}
