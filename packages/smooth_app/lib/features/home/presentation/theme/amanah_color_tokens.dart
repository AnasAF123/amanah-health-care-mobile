import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_visual_role.dart';

class AmanahTone {
  const AmanahTone({
    required this.primary,
    required this.light,
    required this.dark,
    Color? surface,
    Color? onSurface,
    Color? border,
  }) : surface = surface ?? light,
       onSurface = onSurface ?? dark,
       border = border ?? light;

  final Color primary;
  final Color light;
  final Color dark;
  final Color surface;
  final Color onSurface;
  final Color border;
}

enum AmanahStatusTone {
  brand,
  success,
  warning,
  danger,
  info,
  violet,
  pending,
  approved,
  rejected,
  cancelled,
  neutral,
}

abstract final class AmanahSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

abstract final class AmanahRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double sheet = 32;
  static const double pill = 999;
}

// ignore: avoid_classes_with_only_static_members
abstract final class AmanahElevation {
  static BoxShadow soft({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.22 : 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  static BoxShadow sheet({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.80 : 0.30),
    blurRadius: 45,
    offset: const Offset(0, -12),
  );
}

abstract final class AmanahComponentSize {
  static const double minTouchTarget = 48;
  static const double iconButton = 48;
  static const double buttonSmall = 48;
  static const double buttonMedium = 48;
  static const double buttonLarge = 52;
  static const double buttonHero = 56;
  static const double topAppBar = 56;
  static const double filterBar = 48;
}

// ignore: avoid_classes_with_only_static_members
abstract final class AmanahThemeTokens {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color canvas(BuildContext context) => isDark(context)
      ? AmanahColorTokens.canvasDark
      : AmanahColorTokens.canvasLight;

  static Color surface(BuildContext context) => isDark(context)
      ? AmanahColorTokens.surfaceDark
      : AmanahColorTokens.surfaceLight;

  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceElevatedDark : Colors.white;

  static Color surfaceMuted(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.05)
      : AmanahColorTokens.neutral50;

  static Color outline(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.10)
      : AmanahColorTokens.neutral200;

  static Color outlineStrong(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.18)
      : AmanahColorTokens.neutral300;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : AmanahColorTokens.neutral950;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? AmanahColorTokens.neutral300
      : AmanahColorTokens.neutral600;

  static Color textTertiary(BuildContext context) => isDark(context)
      ? AmanahColorTokens.neutral400
      : AmanahColorTokens.neutral500;

  static Color scrim(BuildContext context) =>
      Colors.black.withValues(alpha: isDark(context) ? 0.72 : 0.60);

  static AmanahTone status(AmanahStatusTone tone) {
    switch (tone) {
      case AmanahStatusTone.brand:
      case AmanahStatusTone.info:
      case AmanahStatusTone.pending:
        return const AmanahTone(
          primary: AmanahColorTokens.brand,
          light: AmanahColorTokens.brandSurface,
          dark: AmanahColorTokens.brandAccent,
          onSurface: Color(0xFF1D4ED8),
          border: AmanahColorTokens.brandMuted,
        );
      case AmanahStatusTone.success:
      case AmanahStatusTone.approved:
        return const AmanahTone(
          primary: AmanahColorTokens.success,
          light: AmanahColorTokens.successSurface,
          dark: AmanahColorTokens.successDark,
          onSurface: AmanahColorTokens.successDark,
          border: AmanahColorTokens.successBorder,
        );
      case AmanahStatusTone.warning:
        return const AmanahTone(
          primary: AmanahColorTokens.warning,
          light: AmanahColorTokens.warningSurface,
          dark: AmanahColorTokens.warningDark,
          onSurface: AmanahColorTokens.warningDark,
          border: AmanahColorTokens.warningBorder,
        );
      case AmanahStatusTone.danger:
      case AmanahStatusTone.rejected:
        return const AmanahTone(
          primary: AmanahColorTokens.danger,
          light: AmanahColorTokens.dangerSurface,
          dark: AmanahColorTokens.dangerDark,
          onSurface: AmanahColorTokens.dangerDark,
          border: AmanahColorTokens.dangerBorder,
        );
      case AmanahStatusTone.violet:
        return const AmanahTone(
          primary: AmanahColorTokens.violet,
          light: AmanahColorTokens.violetSurface,
          dark: AmanahColorTokens.violetDark,
          onSurface: AmanahColorTokens.violetDark,
          border: AmanahColorTokens.violetBorder,
        );
      case AmanahStatusTone.cancelled:
      case AmanahStatusTone.neutral:
        return const AmanahTone(
          primary: AmanahColorTokens.neutral500,
          light: AmanahColorTokens.neutral100,
          dark: AmanahColorTokens.neutral700,
          onSurface: AmanahColorTokens.neutral700,
          border: AmanahColorTokens.neutral200,
        );
    }
  }

  static AmanahTone iconTone(AmanahIconTone tone) {
    switch (tone) {
      case AmanahIconTone.brand:
      case AmanahIconTone.account:
      case AmanahIconTone.queue:
      case AmanahIconTone.info:
        return const AmanahTone(
          primary: AmanahColorTokens.brandAccent,
          light: AmanahColorTokens.brandSoft,
          dark: Color(0xFF1D4ED8),
        );
      case AmanahIconTone.practice:
      case AmanahIconTone.shift:
      case AmanahIconTone.warning:
        return const AmanahTone(
          primary: AmanahColorTokens.warning,
          light: Color(0xFFFCD34D),
          dark: AmanahColorTokens.warningDark,
        );
      case AmanahIconTone.security:
      case AmanahIconTone.success:
        return const AmanahTone(
          primary: AmanahColorTokens.success,
          light: Color(0xFF6EE7B7),
          dark: AmanahColorTokens.successDark,
        );
      case AmanahIconTone.notifications:
      case AmanahIconTone.clinicalCritical:
      case AmanahIconTone.danger:
        return const AmanahTone(
          primary: AmanahColorTokens.danger,
          light: Color(0xFFFCA5A5),
          dark: AmanahColorTokens.dangerDark,
        );
      case AmanahIconTone.help:
      case AmanahIconTone.clinicalConsult:
      case AmanahIconTone.violet:
        return const AmanahTone(
          primary: AmanahColorTokens.violet,
          light: Color(0xFFC4B5FD),
          dark: AmanahColorTokens.violetDark,
        );
      case AmanahIconTone.data:
        return const AmanahTone(
          primary: AmanahColorTokens.brandLight,
          light: AmanahColorTokens.brandSubtle,
          dark: Color(0xFF1E40AF),
        );
      case AmanahIconTone.documents:
        return const AmanahTone(
          primary: AmanahColorTokens.brand,
          light: AmanahColorTokens.brandSubtle,
          dark: AmanahColorTokens.auroraSapphireDark,
        );
      case AmanahIconTone.neutral:
        return const AmanahTone(
          primary: AmanahColorTokens.neutral500,
          light: AmanahColorTokens.neutral300,
          dark: AmanahColorTokens.neutral700,
        );
    }
  }
}

/// Centralized Design System & Color Tokens for Amanah Healthcare Portal
/// Matching 1:1 with global.css and Tailwind design tokens in .web/src/styles/global.css
abstract final class AmanahColorTokens {
  // ---------------------------------------------------------------------------
  // 1. Core Brand Colors (Established Medical Blue System)
  // ---------------------------------------------------------------------------
  /// --color-portal-brand: #0d66e9 (Amanah Electric Sapphire Brand Blue)
  static const Color brand = Color(0xFF0D66E9);

  /// Primary Bold Electric Blue (#0A44FF)
  static const Color brandPrimary = Color(0xFF0A44FF);

  /// Radiant Cobalt Blue (#2563EB)
  static const Color brandAccent = Color(0xFF2563EB);

  /// Sky Blue 500 (#3B82F6)
  static const Color brandLight = Color(0xFF3B82F6);

  /// Soft Blue 400 (#60A5FA)
  static const Color brandSoft = Color(0xFF60A5FA);

  /// Subtle Blue 300 (#93C5FD)
  static const Color brandSubtle = Color(0xFF93C5FD);

  /// Light Surface Blue 50 (#EFF6FF)
  static const Color brandSurface = Color(0xFFEFF6FF);

  /// Muted Border Blue 100 (#DBEAFE)
  static const Color brandMuted = Color(0xFFDBEAFE);

  /// --color-portal-emerald: #38c474 (Medical Success Emerald)
  static const Color emerald = Color(0xFF38C474);

  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerStrong = Color(0xFFFB2C36);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color dangerSurface = Color(0xFFFFF1F2);
  static const Color dangerBorder = Color(0xFFFECDD3);

  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDark = Color(0xFF6D28D9);
  static const Color violetSurface = Color(0xFFF5F3FF);
  static const Color violetBorder = Color(0xFFDDD6FE);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF020617);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF0A0E1A);
  static const Color surfaceElevatedDark = Color(0xFF111624);

  /// --color-portal-navy: #1c1645 (Deep Royal Navy)
  static const Color navy = Color(0xFF1C1645);

  /// --color-portal-dark-navy: #14103b (Cosmic Dark Midnight Navy)
  static const Color darkNavy = Color(0xFF14103B);

  /// --color-portal-heading: #1a1d2e (Primary Heading Charcoal)
  static const Color heading = Color(0xFF1A1D2E);

  /// --color-portal-muted: #4a4f63 (Muted Subtitle Grey)
  static const Color muted = Color(0xFF4A4F63);

  /// --color-portal-bg: #f8faff (Crisp Healthcare Portal Canvas Background)
  static const Color canvasLight = Color(0xFFF8FAFF);

  /// Dark Mode Canvas Background (#0a0e1a)
  static const Color canvasDark = Color(0xFF0A0E1A);

  // ---------------------------------------------------------------------------
  // 2. Harmonized Crisp Button System (.btn-crisp-blue from global.css)
  // ---------------------------------------------------------------------------
  /// Light Mode Crisp Blue Button Linear Gradient (#3B8AEB top sheen -> #0D66E9 base sapphire)
  static const LinearGradient btnCrispBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF3B8AEB), // top specular sheen highlight
      Color(0xFF0D66E9), // base sapphire brand blue
    ],
  );

  /// Dark Mode Crisp Blue Button Gradient (.btn-crisp-blue-dark)
  static const LinearGradient btnCrispBlueDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF3B82F6), // blue 500 highlight
      Color(0xFF2563EB), // cobalt blue 600
      Color(0xFF1D4ED8), // deep royal blue 700
    ],
  );

  /// Light Mode Crisp Blue Stroke Border (#1D58AC)
  static const Color btnCrispBlueBorder = Color(0xFF1D58AC);

  /// Dark Mode Crisp Blue Stroke Border (rgba(59, 130, 246, 0.55))
  static const Color btnCrispBlueDarkBorder = Color(0x8C3B82F6);

  /// Crisp Blue Button Inset Specular Sheen (rgba(255, 255, 255, 0.28))
  static const Color btnSpecularSheen = Color(0x47FFFFFF);

  /// Crisp Blue Button Drop Shadow (0px 1px 2px rgba(0, 0, 0, 0.12))
  static const BoxShadow btnCrispDropShadow = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  /// Crisp Blue Button Glow Shadow in Light Mode
  static const BoxShadow btnCrispBlueShadow = BoxShadow(
    color: Color(0x3D0D66E9),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  /// Crisp Blue Button Glow Shadow in Dark Mode
  static const BoxShadow btnCrispBlueDarkShadow = BoxShadow(
    color: Color(0x4D2563EB),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  // ---------------------------------------------------------------------------
  // 3. Floating Heroic QR Action Button (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  /// QR Button Outer Halo Shadow in Light Mode (0px 8px 24px rgba(13, 102, 233, 0.35))
  static const BoxShadow qrButtonShadowLight = BoxShadow(
    color: Color(0x590D66E9),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  /// QR Button Outer Halo Shadow in Dark Mode (0px 8px 24px rgba(37, 99, 235, 0.30))
  static const BoxShadow qrButtonShadowDark = BoxShadow(
    color: Color(0x4D2563EB),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  /// QR Outer Ring Color Light (4px white ring)
  static const Color qrRingLight = Colors.white;

  /// QR Outer Ring Color Dark (4px neutral-950 ring)
  static const Color qrRingDark = Color(0xFF0A0A0A);

  // ---------------------------------------------------------------------------
  // 4. Navigation & Tab Accent Tokens (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  /// Active tab text & icon in Light Mode (#0D66E9)
  static const Color tabActiveLight = Color(0xFF0D66E9);

  /// Active tab text & icon in Dark Mode (text-blue-400: #60A5FA)
  static const Color tabActiveDark = Color(0xFF60A5FA);

  /// Inactive tab text & icon in Light Mode (#9CA3AF)
  static const Color tabInactiveLight = Color(0xFF9CA3AF);

  /// Inactive tab text & icon in Dark Mode (#737373)
  static const Color tabInactiveDark = Color(0xFF737373);

  // ---------------------------------------------------------------------------
  // 5. Dynamic Aurora Ambient Atmosphere Tokens (from AuroraBackground.tsx)
  // ---------------------------------------------------------------------------
  /// Light Mode Aurora Primary Glow (Amanah Electric Sapphire #0D66E9)
  static const Color auroraSapphireLight = Color(0xFF0D66E9);

  /// Light Mode Aurora Secondary Glow (Cobalt Blue #2563EB)
  static const Color auroraAccentLight = Color(0xFF2563EB);
  static const Color auroraBlueLight = Color(0xFF2563EB);

  /// Dark Mode Aurora Primary Glow (Deep Cosmic Sapphire #07247A)
  static const Color auroraSapphireDark = Color(0xFF07247A);

  /// Dark Mode Aurora Secondary Glow (Royal Blue #1D4ED8)
  static const Color auroraAccentDark = Color(0xFF1D4ED8);
  static const Color auroraBlueDark = Color(0xFF1D4ED8);
}
