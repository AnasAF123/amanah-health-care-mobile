// ignore_for_file: avoid_classes_with_only_static_members
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

abstract final class AmanahElevation {
  static BoxShadow soft({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.28 : 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );

  static BoxShadow card({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.35 : 0.04),
    blurRadius: 12,
    offset: const Offset(0, 3),
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

/// Centralized Semantic Theme Tokens for Amanah Mobile Application.
///
/// Complies with the production dark mode design system and the extracted CSS palette
/// from color-palette-1788452212858.css.
///
/// Components consume these semantic roles rather than guessing raw hex colors.
abstract final class AmanahThemeTokens {
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Surface & Canvas Hierarchy
  // ---------------------------------------------------------------------------
  /// Deepest screen canvas background (#060B18 in dark, #F8FAFF in light)
  static Color canvas(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;

  /// Secondary screen canvas background (#0A0F1D in dark, #F8FAFC in light)
  static Color canvasAlt(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.canvasAltDark : AmanahColorTokens.neutral50;

  /// Level 1 Card Surface (#0B1329 in dark, #FFFFFF in light)
  static Color surface(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight;

  /// Level 2 Inset / Sub-card Container Surface (#0F1629 in dark, #F8FAFC in light)
  static Color surfaceSecondary(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.neutral50;

  /// Level 3 Elevated Surface for Modals, Drawers, Sheets (#131B2E in dark, #FFFFFF in light)
  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceElevatedDark : Colors.white;

  /// Level 4 High Elevation for Popovers, Dialogs (#16233D in dark, #FFFFFF in light)
  static Color surfaceHighest(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceHighestDark : Colors.white;

  /// Highlight Surface: Navy-Blue Tinted (#082F49 in dark, #EFF6FF in light)
  static Color surfaceHighlight(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceAccentDark : AmanahColorTokens.brandSurface;

  /// Subtle muted container surface (fields, chips, inactive tabs)
  static Color surfaceMuted(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.05)
      : AmanahColorTokens.neutral100;

  // ---------------------------------------------------------------------------
  // Outlines & Dividers
  // ---------------------------------------------------------------------------
  /// Standard structural outline/border (rgba(255,255,255,0.08) in dark, #E2E8F0 in light)
  static Color outline(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : AmanahColorTokens.neutral200;

  /// High-emphasis structural outline (rgba(255,255,255,0.16) in dark, #CBD5E1 in light)
  static Color outlineStrong(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.16)
      : AmanahColorTokens.neutral300;

  /// Structural horizontal/vertical divider
  static Color divider(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : AmanahColorTokens.neutral200;

  // ---------------------------------------------------------------------------
  // Typography & Foregrounds
  // ---------------------------------------------------------------------------
  /// High-emphasis primary text (#FFFFFF in dark, #0F172A in light)
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : AmanahColorTokens.neutral900;

  /// Medium-emphasis secondary text (#CBD5E1 in dark, #475569 in light)
  static Color textSecondary(BuildContext context) => isDark(context)
      ? AmanahColorTokens.neutral300
      : AmanahColorTokens.neutral600;

  /// Low-emphasis tertiary text (#94A3B8 in dark, #64748B in light)
  static Color textTertiary(BuildContext context) => isDark(context)
      ? AmanahColorTokens.neutral400
      : AmanahColorTokens.neutral500;

  /// Muted / placeholder text (#64748B in dark, #94A3B8 in light)
  static Color textMuted(BuildContext context) => isDark(context)
      ? AmanahColorTokens.neutral500
      : AmanahColorTokens.neutral400;

  /// Backdrop scrim for modal sheets and overlays
  static Color scrim(BuildContext context) =>
      Colors.black.withValues(alpha: isDark(context) ? 0.72 : 0.60);

  // ---------------------------------------------------------------------------
  // Adaptive Semantic Status Tones
  // ---------------------------------------------------------------------------
  /// Returns a semantically adapted status tone for the given theme context.
  static AmanahTone statusAdaptive(BuildContext context, AmanahStatusTone tone) =>
      status(tone, isDark: isDark(context));

  /// Resolves [AmanahStatusTone] to light or dark adapted [AmanahTone].
  static AmanahTone status(AmanahStatusTone tone, {bool? isDark, BuildContext? context}) {
    final bool dark = isDark ?? (context != null && AmanahThemeTokens.isDark(context));

    if (dark) {
      switch (tone) {
        case AmanahStatusTone.brand:
        case AmanahStatusTone.info:
        case AmanahStatusTone.pending:
          return AmanahTone(
            primary: AmanahColorTokens.brand,
            light: AmanahColorTokens.brand.withValues(alpha: 0.16),
            dark: AmanahColorTokens.brandAccent,
            surface: AmanahColorTokens.brand.withValues(alpha: 0.16),
            onSurface: const Color(0xFF60A5FA),
            border: AmanahColorTokens.brand.withValues(alpha: 0.32),
          );
        case AmanahStatusTone.success:
        case AmanahStatusTone.approved:
          return AmanahTone(
            primary: AmanahColorTokens.success,
            light: AmanahColorTokens.success.withValues(alpha: 0.16),
            dark: const Color(0xFF34D399),
            surface: AmanahColorTokens.success.withValues(alpha: 0.16),
            onSurface: const Color(0xFF34D399),
            border: AmanahColorTokens.success.withValues(alpha: 0.32),
          );
        case AmanahStatusTone.warning:
          return AmanahTone(
            primary: AmanahColorTokens.warning,
            light: AmanahColorTokens.warning.withValues(alpha: 0.16),
            dark: const Color(0xFFFBBF24),
            surface: AmanahColorTokens.warning.withValues(alpha: 0.16),
            onSurface: const Color(0xFFFBBF24),
            border: AmanahColorTokens.warning.withValues(alpha: 0.32),
          );
        case AmanahStatusTone.danger:
        case AmanahStatusTone.rejected:
          return AmanahTone(
            primary: AmanahColorTokens.danger,
            light: AmanahColorTokens.danger.withValues(alpha: 0.16),
            dark: const Color(0xFFF87171),
            surface: AmanahColorTokens.danger.withValues(alpha: 0.16),
            onSurface: const Color(0xFFF87171),
            border: AmanahColorTokens.danger.withValues(alpha: 0.32),
          );
        case AmanahStatusTone.violet:
          return AmanahTone(
            primary: AmanahColorTokens.violet,
            light: AmanahColorTokens.violet.withValues(alpha: 0.16),
            dark: const Color(0xFFA78BFA),
            surface: AmanahColorTokens.violet.withValues(alpha: 0.16),
            onSurface: const Color(0xFFA78BFA),
            border: AmanahColorTokens.violet.withValues(alpha: 0.32),
          );
        case AmanahStatusTone.cancelled:
        case AmanahStatusTone.neutral:
          return AmanahTone(
            primary: AmanahColorTokens.neutral400,
            light: Colors.white.withValues(alpha: 0.08),
            dark: AmanahColorTokens.neutral300,
            surface: Colors.white.withValues(alpha: 0.08),
            onSurface: AmanahColorTokens.neutral300,
            border: Colors.white.withValues(alpha: 0.14),
          );
      }
    }

    // Light Theme fallback (preserved 1:1)
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

  // ---------------------------------------------------------------------------
  // Category & Functional Icon Tones
  // ---------------------------------------------------------------------------
  static AmanahTone iconTone(AmanahIconTone tone, {bool? isDark, BuildContext? context}) {
    final bool dark = isDark ?? (context != null && AmanahThemeTokens.isDark(context));

    if (dark) {
      switch (tone) {
        case AmanahIconTone.brand:
        case AmanahIconTone.account:
        case AmanahIconTone.queue:
        case AmanahIconTone.info:
          return const AmanahTone(
            primary: AmanahColorTokens.brandLight,
            light: Color(0xFF1E3A8A),
            dark: Color(0xFF60A5FA),
          );
        case AmanahIconTone.practice:
        case AmanahIconTone.shift:
        case AmanahIconTone.warning:
          return const AmanahTone(
            primary: AmanahColorTokens.warning,
            light: Color(0xFF78350F),
            dark: Color(0xFFFBBF24),
          );
        case AmanahIconTone.security:
        case AmanahIconTone.success:
          return const AmanahTone(
            primary: AmanahColorTokens.success,
            light: Color(0xFF064E3B),
            dark: Color(0xFF34D399),
          );
        case AmanahIconTone.notifications:
        case AmanahIconTone.clinicalCritical:
        case AmanahIconTone.danger:
          return const AmanahTone(
            primary: AmanahColorTokens.danger,
            light: Color(0xFF7F1D1D),
            dark: Color(0xFFF87171),
          );
        case AmanahIconTone.help:
        case AmanahIconTone.clinicalConsult:
        case AmanahIconTone.violet:
          return const AmanahTone(
            primary: AmanahColorTokens.violet,
            light: Color(0xFF4C1D95),
            dark: Color(0xFFA78BFA),
          );
        case AmanahIconTone.data:
          return const AmanahTone(
            primary: AmanahColorTokens.brandLight,
            light: Color(0xFF1E3A8A),
            dark: Color(0xFF93C5FD),
          );
        case AmanahIconTone.documents:
          return const AmanahTone(
            primary: AmanahColorTokens.brand,
            light: Color(0xFF1E3A8A),
            dark: Color(0xFF60A5FA),
          );
        case AmanahIconTone.neutral:
          return const AmanahTone(
            primary: AmanahColorTokens.neutral400,
            light: Color(0xFF1E293B),
            dark: AmanahColorTokens.neutral300,
          );
      }
    }

    // Light Theme
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

/// Centralized Design System & Color Tokens for Amanah Healthcare Portal.
///
/// Blue accent system is preserved unchanged (#0D66E9, #2563EB, #0A44FF, etc.).
/// Dark neutral/navy surfaces are aligned with color-palette-1788452212858.css.
abstract final class AmanahColorTokens {
  // ---------------------------------------------------------------------------
  // 1. Core Brand Colors (Preserved Established Medical Blue System)
  // ---------------------------------------------------------------------------
  /// --color-portal-brand: #0D66E9 (Amanah Electric Sapphire Brand Blue)
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

  // ---------------------------------------------------------------------------
  // 2. Semantic Non-Blue Colors (Green, Yellow, Red, Violet)
  // ---------------------------------------------------------------------------
  /// --color-portal-emerald: #38C474 (Medical Success Emerald)
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

  // ---------------------------------------------------------------------------
  // 3. Neutrals (Light & Dark Foundations)
  // ---------------------------------------------------------------------------
  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral950 = Color(0xFF020617);

  // ---------------------------------------------------------------------------
  // 4. Surfaces Aligned with color-palette-1788452212858.css
  // ---------------------------------------------------------------------------
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Level 1 Card Surface (#0B1329 - CSS --color-7, used 135x)
  static const Color surfaceDark = Color(0xFF0B1329);

  /// Level 2 Inset / Sub-card Container Surface (#0F1629 - CSS --color-49)
  static const Color surfaceSecondaryDark = Color(0xFF0F1629);

  /// Level 3 Elevated Surface: Modals, Drawers, Sheets (#131B2E - CSS --color-47)
  static const Color surfaceElevatedDark = Color(0xFF131B2E);

  /// Level 4 Highest Elevation: Popovers, Dialogs (#16233D - CSS --color-48)
  static const Color surfaceHighestDark = Color(0xFF16233D);

  /// Level 5 Accent Container Navy (#082F49 - CSS --color-6)
  static const Color surfaceAccentDark = Color(0xFF082F49);

  /// Deep Canvas Background (#060B18 - CSS --color-9)
  static const Color canvasDark = Color(0xFF060B18);

  /// Secondary Canvas Background (#0A0F1D - CSS --color-50)
  static const Color canvasAltDark = Color(0xFF0A0F1D);

  /// Crisp Healthcare Portal Canvas Background (#F8FAFF)
  static const Color canvasLight = Color(0xFFF8FAFF);

  /// --color-portal-navy: #1C1645 (Deep Royal Navy)
  static const Color navy = Color(0xFF1C1645);

  /// --color-portal-dark-navy: #14103B (Cosmic Dark Midnight Navy)
  static const Color darkNavy = Color(0xFF14103B);

  /// --color-portal-heading: #1A1D2E (Primary Heading Charcoal)
  static const Color heading = Color(0xFF1A1D2E);

  /// --color-portal-muted: #4A4F63 (Muted Subtitle Grey)
  static const Color muted = Color(0xFF4A4F63);

  // ---------------------------------------------------------------------------
  // 5. Harmonized Crisp Button System (.btn-crisp-blue from global.css)
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
  // 6. Floating Heroic QR Action Button (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  static const BoxShadow qrButtonShadowLight = BoxShadow(
    color: Color(0x590D66E9),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow qrButtonShadowDark = BoxShadow(
    color: Color(0x4D2563EB),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const Color qrRingLight = Colors.white;
  static const Color qrRingDark = Color(0xFF0B1329);

  // ---------------------------------------------------------------------------
  // 7. Navigation & Tab Accent Tokens (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  static const Color tabActiveLight = Color(0xFF0D66E9);
  static const Color tabActiveDark = Color(0xFF60A5FA);
  static const Color tabInactiveLight = Color(0xFF9CA3AF);
  static const Color tabInactiveDark = Color(0xFF737373);

  // ---------------------------------------------------------------------------
  // 8. Dynamic Aurora Ambient Atmosphere Tokens (from AuroraBackground.tsx)
  // ---------------------------------------------------------------------------
  static const Color auroraSapphireLight = Color(0xFF0D66E9);
  static const Color auroraAccentLight = Color(0xFF2563EB);
  static const Color auroraBlueLight = Color(0xFF2563EB);

  static const Color auroraSapphireDark = Color(0xFF07247A);
  static const Color auroraAccentDark = Color(0xFF1D4ED8);
  static const Color auroraBlueDark = Color(0xFF1D4ED8);
}
