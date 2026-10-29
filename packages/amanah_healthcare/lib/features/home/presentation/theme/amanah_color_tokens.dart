// ignore_for_file: avoid_classes_with_only_static_members
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';

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

/// Shadcn-style elevation: almost flat in light mode (hairline + whisper
/// shadow), deep and tight in dark mode so cards separate from the canvas
/// without needing bright borders.
abstract final class AmanahElevation {
  static BoxShadow soft({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.45 : 0.06),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );

  static BoxShadow card({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.55 : 0.05),
    blurRadius: dark ? 10 : 6,
    offset: const Offset(0, 1),
  );

  static BoxShadow sheet({required bool dark}) => BoxShadow(
    color: Colors.black.withValues(alpha: dark ? 0.90 : 0.14),
    blurRadius: 40,
    offset: const Offset(0, -10),
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
/// Design direction:
/// * Light  -> shadcn/ui look: pure white canvas, zinc neutrals, hairline
///             borders, brand blue used sparingly.
/// * Dark   -> near-black, very slightly blue-tinted surfaces (OLED friendly)
///             with a strict elevation ladder. The accent stays inside ONE
///             hue family (blue 400 -> 600). No cyan/purple jumps.
///
/// Components consume these semantic roles rather than guessing raw hex colors.
abstract final class AmanahThemeTokens {
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Surface & Canvas Hierarchy
  // ---------------------------------------------------------------------------
  /// Deepest screen canvas background (#05070B in dark, #FFFFFF in light)
  static Color canvas(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;

  /// Secondary screen canvas background (#080B11 in dark, #FAFAFA in light)
  static Color canvasAlt(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.canvasAltDark : AmanahColorTokens.neutral50;

  /// Level 1 Card Surface (#0B0F16 in dark, #FFFFFF in light)
  static Color surface(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight;

  /// Level 2 Inset / Sub-card Container Surface (#10151E in dark, #FAFAFA in light)
  static Color surfaceSecondary(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceSecondaryDark : AmanahColorTokens.neutral50;

  /// Level 3 Elevated Surface for Modals, Drawers, Sheets (#151B26 in dark, #FFFFFF in light)
  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceElevatedDark : Colors.white;

  /// Level 4 High Elevation for Popovers, Dialogs (#1B2230 in dark, #FFFFFF in light)
  static Color surfaceHighest(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceHighestDark : Colors.white;

  /// Highlight Surface: Navy-Blue Tinted (#0A1B3D in dark, #EFF6FF in light)
  static Color surfaceHighlight(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.surfaceAccentDark : AmanahColorTokens.brandSurface;

  /// Subtle muted container surface (fields, chips, inactive tabs)
  static Color surfaceMuted(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.05) : AmanahColorTokens.neutral100;

  // ---------------------------------------------------------------------------
  // Outlines & Dividers
  // ---------------------------------------------------------------------------
  /// Standard structural outline/border (rgba(255,255,255,0.08) in dark, #E4E4E7 in light)
  static Color outline(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.08) : AmanahColorTokens.neutral200;

  /// High-emphasis structural outline (rgba(255,255,255,0.14) in dark, #D4D4D8 in light)
  static Color outlineStrong(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.14) : AmanahColorTokens.neutral300;

  /// Structural horizontal/vertical divider
  static Color divider(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.08) : AmanahColorTokens.neutral200;

  // ---------------------------------------------------------------------------
  // Typography & Foregrounds
  // ---------------------------------------------------------------------------
  /// High-emphasis primary text (#FAFAFA in dark, #09090B in light)
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.neutral50 : AmanahColorTokens.neutral950;

  /// Medium-emphasis secondary text (#D4D4D8 in dark, #52525B in light)
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral600;

  /// Low-emphasis tertiary text (#A1A1AA in dark, #71717A in light)
  static Color textTertiary(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

  /// Muted / placeholder text (#71717A in dark, #A1A1AA in light)
  static Color textMuted(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.neutral500 : AmanahColorTokens.neutral400;

  /// Backdrop scrim for modal sheets and overlays
  static Color scrim(BuildContext context) =>
      Colors.black.withValues(alpha: isDark(context) ? 0.80 : 0.50);

  /// Interactive accent. Dark mode stays in the same blue family as the brand
  /// (blue 400) instead of jumping to cyan.
  static Color accent(BuildContext context) =>
      isDark(context) ? AmanahColorTokens.brandSoft : AmanahColorTokens.brand;

  static Color accentSurface(BuildContext context) => isDark(context)
      ? AmanahColorTokens.surfaceAccentDark.withValues(alpha: 0.70)
      : AmanahColorTokens.brandSurface;

  static Color accentBorder(BuildContext context) => isDark(context)
      ? AmanahColorTokens.brandLight.withValues(alpha: 0.30)
      : AmanahColorTokens.brandMuted;

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
      // Dark tones: low-alpha tinted fill + same-hue border + bright foreground.
      switch (tone) {
        case AmanahStatusTone.brand:
        case AmanahStatusTone.info:
        case AmanahStatusTone.pending:
          return AmanahTone(
            primary: AmanahColorTokens.tabActiveDark,
            light: AmanahColorTokens.tabActiveDark.withValues(alpha: 0.14),
            dark: AmanahColorTokens.tabActiveDark,
            surface: AmanahColorTokens.tabActiveDark.withValues(alpha: 0.14),
            onSurface: AmanahColorTokens.tabActiveDark,
            border: AmanahColorTokens.tabActiveDark.withValues(alpha: 0.30),
          );
        case AmanahStatusTone.success:
        case AmanahStatusTone.approved:
          return AmanahTone(
            primary: AmanahColorTokens.success,
            light: AmanahColorTokens.success.withValues(alpha: 0.14),
            dark: const Color(0xFF34D399),
            surface: AmanahColorTokens.success.withValues(alpha: 0.14),
            onSurface: const Color(0xFF34D399),
            border: AmanahColorTokens.success.withValues(alpha: 0.30),
          );
        case AmanahStatusTone.warning:
          return AmanahTone(
            primary: AmanahColorTokens.warning,
            light: AmanahColorTokens.warning.withValues(alpha: 0.14),
            dark: const Color(0xFFFBBF24),
            surface: AmanahColorTokens.warning.withValues(alpha: 0.14),
            onSurface: const Color(0xFFFBBF24),
            border: AmanahColorTokens.warning.withValues(alpha: 0.30),
          );
        case AmanahStatusTone.danger:
        case AmanahStatusTone.rejected:
          return AmanahTone(
            primary: AmanahColorTokens.danger,
            light: AmanahColorTokens.danger.withValues(alpha: 0.14),
            dark: const Color(0xFFF87171),
            surface: AmanahColorTokens.danger.withValues(alpha: 0.14),
            onSurface: const Color(0xFFF87171),
            border: AmanahColorTokens.danger.withValues(alpha: 0.30),
          );
        case AmanahStatusTone.violet:
          // Indigo-leaning so it sits next to the blue brand instead of clashing.
          return AmanahTone(
            primary: AmanahColorTokens.violet,
            light: AmanahColorTokens.violet.withValues(alpha: 0.14),
            dark: const Color(0xFF818CF8),
            surface: AmanahColorTokens.violet.withValues(alpha: 0.14),
            onSurface: const Color(0xFF818CF8),
            border: AmanahColorTokens.violet.withValues(alpha: 0.30),
          );
        case AmanahStatusTone.cancelled:
        case AmanahStatusTone.neutral:
          return AmanahTone(
            primary: AmanahColorTokens.neutral400,
            light: Colors.white.withValues(alpha: 0.06),
            dark: AmanahColorTokens.neutral300,
            surface: Colors.white.withValues(alpha: 0.06),
            onSurface: AmanahColorTokens.neutral300,
            border: Colors.white.withValues(alpha: 0.12),
          );
      }
    }

    // Light Theme (shadcn style: pale tinted fill, hairline border, strong text)
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
      // Dark: `light` = very deep tinted container, `dark` = bright foreground.
      switch (tone) {
        case AmanahIconTone.brand:
        case AmanahIconTone.account:
        case AmanahIconTone.queue:
        case AmanahIconTone.info:
          return const AmanahTone(
            primary: AmanahColorTokens.brandLight,
            light: Color(0xFF0E2250),
            dark: Color(0xFF60A5FA),
          );
        case AmanahIconTone.practice:
        case AmanahIconTone.shift:
        case AmanahIconTone.warning:
          return const AmanahTone(
            primary: AmanahColorTokens.warning,
            light: Color(0xFF32200A),
            dark: Color(0xFFFBBF24),
          );
        case AmanahIconTone.security:
        case AmanahIconTone.success:
          return const AmanahTone(
            primary: AmanahColorTokens.success,
            light: Color(0xFF05281D),
            dark: Color(0xFF34D399),
          );
        case AmanahIconTone.notifications:
        case AmanahIconTone.clinicalCritical:
        case AmanahIconTone.danger:
          return const AmanahTone(
            primary: AmanahColorTokens.danger,
            light: Color(0xFF3A1111),
            dark: Color(0xFFF87171),
          );
        case AmanahIconTone.help:
        case AmanahIconTone.clinicalConsult:
        case AmanahIconTone.violet:
          return const AmanahTone(
            primary: AmanahColorTokens.violet,
            light: Color(0xFF1A1D4A),
            dark: Color(0xFF818CF8),
          );
        case AmanahIconTone.data:
          return const AmanahTone(
            primary: AmanahColorTokens.brandLight,
            light: Color(0xFF0E2250),
            dark: Color(0xFF93C5FD),
          );
        case AmanahIconTone.documents:
          return const AmanahTone(
            primary: AmanahColorTokens.brand,
            light: Color(0xFF0E2250),
            dark: Color(0xFF60A5FA),
          );
        case AmanahIconTone.neutral:
          return const AmanahTone(
            primary: AmanahColorTokens.neutral400,
            light: Color(0xFF171A21),
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
          light: Color(0xFFA5B4FC),
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
/// * Light brand blue is preserved (#0D66E9, #2563EB, #0A44FF ...).
/// * Neutrals are now zinc (shadcn default) instead of slate.
/// * Dark surfaces are a near-black ladder with a faint blue tint.
/// * Dark accent family is blue 400/500/600 only (cyan/sky no longer drives
///   dark UI). Old token names are kept so existing widgets keep compiling.
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

  /// Soft Blue 400 (#60A5FA) - the accent used on dark surfaces
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
  static const Color destructive = danger;

  /// "Violet" status role, now indigo-leaning (#6366F1) so it harmonizes with
  /// the blue brand instead of looking like a separate purple theme.
  static const Color violet = Color(0xFF6366F1);
  static const Color violetDark = Color(0xFF4338CA);
  static const Color violetSurface = Color(0xFFEEF2FF);
  static const Color violetBorder = Color(0xFFC7D2FE);
  static const Color sky = Color(0xFF0284C7);
  static const Color skySoft = Color(0xFF38BDF8);
  static const Color skySurface = Color(0xFFF0F9FF);
  static const Color skyLight = Color(0xFFE0F2FE);
  static const Color skySubtle = Color(0xFFBAE6FD);
  static const Color skyDark = Color(0xFF0369A1);
  static const Color skyDeep = Color(0xFF0096C7);
  static const Color skyMedium = Color(0xFF0EA5E9);
  static const Color cyanDark = Color(0xFF0E7490);
  static const Color cyanBright = Color(0xFF00D3F2);
  static const Color cyanLight = Color(0xFF67E8F9);
  static const Color indigoDark = Color(0xFF101A3C);
  static const Color cyanAccent = Color(0xFF22D3EE);
  static const Color brandNavy = Color(0xFF0A1B3D);
  static const Color brandNavyDark = Color(0xFF05070B);
  static const Color navySurface = Color(0xFF0B0F16);
  static const Color amberDark = Color(0xFFB45309);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color amberBorderDark = Color(0xFF78350F);
  static const Color amberBgDark = Color(0xFF140F06);
  static const Color amberBgDarker = Color(0xFF100B05);
  static const Color amberSurfaceLight = Color(0xFFFFFBEB);
  static const Color amberSurfaceSoft = Color(0xFFFEF3C7);
  static const Color amberBorderLight = Color(0xFFFDE68A);
  static const Color featherGrayLight = Color(0xFFD5DBE3);
  static const Color featherGray = Color(0xFFB4BECC);
  static const Color mailAirLight = Color(0xFFBBF2F6);
  static const Color mailAir = Color(0xFF8DE0F7);
  static const Color mailAirBorder = Color(0xFF74C5E3);

  // ---------------------------------------------------------------------------
  // 3. Neutrals (Zinc scale, same as shadcn/ui)
  // ---------------------------------------------------------------------------
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF4F4F5);
  static const Color neutral200 = Color(0xFFE4E4E7);
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF52525B);
  static const Color neutral700 = Color(0xFF3F3F46);
  static const Color neutral800 = Color(0xFF27272A);
  static const Color neutral900 = Color(0xFF18181B);
  static const Color neutral950 = Color(0xFF09090B);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color textShadowBlack20 = Color(0x33000000);
  static const Color textWhite85 = Color(0xD9FFFFFF);

  // ---------------------------------------------------------------------------
  // 4. Surfaces (dark elevation ladder: each step is only ~4-6 units brighter)
  // ---------------------------------------------------------------------------
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Level 1 Card Surface (#0B0F16)
  static const Color surfaceDark = Color(0xFF0B0F16);
  static const Color cardDark = surfaceDark;

  /// Level 2 Inset / Sub-card Container Surface (#10151E)
  static const Color surfaceSecondaryDark = Color(0xFF10151E);

  /// Level 3 Elevated Surface: Modals, Drawers, Sheets (#151B26)
  static const Color surfaceElevatedDark = Color(0xFF151B26);

  /// Level 4 Highest Elevation: Popovers, Dialogs (#1B2230)
  static const Color surfaceHighestDark = Color(0xFF1B2230);

  /// Level 5 Accent Container Navy (#0A1B3D) - deep blue, same hue as brand
  static const Color surfaceAccentDark = Color(0xFF0A1B3D);

  /// Deep Canvas Background (#05070B) - darker than before, OLED friendly
  static const Color canvasDark = Color(0xFF05070B);

  /// Secondary Canvas Background (#080B11)
  static const Color canvasAltDark = Color(0xFF080B11);

  /// Healthcare Portal Canvas Background (#FFFFFF) - pure white like shadcn
  static const Color canvasLight = Color(0xFFFFFFFF);

  /// --color-portal-navy: #0B1A3F (Deep Royal Navy, now blue not purple)
  static const Color navy = Color(0xFF0B1A3F);

  /// --color-portal-dark-navy: #071230 (Midnight Navy)
  static const Color darkNavy = Color(0xFF071230);

  /// --color-portal-heading: #09090B (Primary Heading, zinc 950)
  static const Color heading = Color(0xFF09090B);

  /// --color-portal-muted: #52525B (Muted Subtitle, zinc 600)
  static const Color muted = Color(0xFF52525B);

  // ---------------------------------------------------------------------------
  // 5. Harmonized Crisp Button System (.btn-crisp-blue & .btn-crisp-soft)
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

  /// Dark Mode Crisp Blue Button Gradient (blue 400 highlight -> blue 600 base -> blue 700)
  /// Same hue family as the light button; no more sky/cyan jump.
  static const LinearGradient btnCrispBlueDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF60A5FA), // blue 400 top specular highlight
      Color(0xFF2563EB), // blue 600 base
      Color(0xFF1D4ED8), // blue 700 bottom extrusion
    ],
  );

  /// Light Mode Crisp Blue Stroke Border (#1D58AC)
  static const Color btnCrispBlueBorder = Color(0xFF1D58AC);

  /// Dark Mode Crisp Blue Stroke Border (0.8px solid rgba(96, 165, 250, 0.55))
  static const Color btnCrispBlueDarkBorder = Color(0x8C60A5FA);

  /// Crisp Blue Button Inset Specular Sheen (rgba(255, 255, 255, 0.28))
  static const Color btnSpecularSheen = Color(0x47FFFFFF);

  /// Crisp Blue Button Drop Shadow (0px 1px 2px rgba(0, 0, 0, 0.12))
  static const BoxShadow btnCrispDropShadow = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  /// Crisp Blue Button Glow Shadow in Light Mode (softer, shadcn-like)
  static const BoxShadow btnCrispBlueShadow = BoxShadow(
    color: Color(0x330D66E9),
    blurRadius: 10,
    offset: Offset(0, 4),
  );

  /// Crisp Blue Button Shadow in Dark Mode (deep black, no glow)
  static const BoxShadow btnCrispBlueDarkShadow = BoxShadow(
    color: Color(0x80000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  );

  /// Dark Mode Crisp Soft Button Gradient (.btn-crisp-soft-dark)
  static const LinearGradient btnCrispSoftDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0x2E60A5FA), // rgba(96, 165, 250, 0.18)
      Color(0x0A2563EB), // rgba(37, 99, 235, 0.04)
    ],
  );

  /// Dark Mode Crisp Soft Button Background (rgba(37, 99, 235, 0.14))
  static const Color btnCrispSoftDarkBg = Color(0x242563EB);

  /// Dark Mode Crisp Soft Button Border (0.8px solid rgba(96, 165, 250, 0.30))
  static const Color btnCrispSoftDarkBorder = Color(0x4D60A5FA);

  /// Dark Mode Crisp Soft Button Foreground (#60A5FA)
  static const Color btnCrispSoftDarkText = Color(0xFF60A5FA);

  // ---------------------------------------------------------------------------
  // 6. Floating Heroic QR Action Button (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  static const BoxShadow qrButtonShadowLight = BoxShadow(
    color: Color(0x590D66E9),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const BoxShadow qrButtonShadowDark = BoxShadow(
    color: Color(0x4D3B82F6), // rgba(59,130,246,0.3) blue glow, same hue as brand
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  static const Color qrRingLight = Colors.white;
  static const Color qrRingDark = Color(0xFF05070B);

  // ---------------------------------------------------------------------------
  // 7. Navigation & Tab Accent Tokens (from BottomNavBar.tsx)
  // ---------------------------------------------------------------------------
  static const Color tabActiveLight = Color(0xFF0D66E9);
  static const Color tabActiveDark = Color(
    0xFF60A5FA,
  ); // blue 400 (same family as brand, replaces the old cyan/sky accent)
  static const Color tabInactiveLight = Color(0xFFA1A1AA); // zinc 400
  static const Color tabInactiveDark = Color(0xFF71717A); // zinc 500

  // ---------------------------------------------------------------------------
  // 8. Dynamic Aurora Ambient Atmosphere Tokens (from AuroraBackground.tsx)
  // ---------------------------------------------------------------------------
  static const Color auroraSapphireLight = Color(0xFF0D66E9);
  static const Color auroraAccentLight = Color(0xFF2563EB);
  static const Color auroraBlueLight = Color(0xFF2563EB);

  static const Color auroraSapphireDark = Color(0xFF061B4D);
  static const Color auroraAccentDark = Color(0xFF1E40AF);
  static const Color auroraBlueDark = Color(0xFF1E40AF);

  /// Name kept for compatibility. Value is now a blue (#3B82F6), not cyan,
  /// so the dark aurora stays in the brand hue.
  static const Color auroraCyanDark = Color(0xFF3B82F6);

  /// Name kept for compatibility. Value is now blue 400 (#60A5FA).
  static const Color auroraCyanLuminousDark = Color(0xFF60A5FA);
  static const Color brandNavyBold = Color(0xFF1E40AF);
  static const Color brandDarkNavy = Color(0xFF1E3A8A);
  static const Color brandIndigoNavy = Color(0xFF0E3A7A);
  static const Color brandPale = Color(0xFFBFDBFE);
  static const Color badgeDepthDark = Color(0xFF051733);
  static const Color badgeDepthLight = Color(0xFF0F2B66);
  static const Color brandMidnight = Color(0xFF172554);
  static const Color surfaceSecondaryLight = Color(0xFFFAFAFA);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color roseLight = Color(0xFFFB7185);
  static const Color auroraFluidHazeLight = Color(0xFF70A6FF);
  static const Color dockCavityDark = Color(0xFF020305);
  static const Color dockCavityDeep = Color(0xFF010102);
  static const Color dockSurfaceDarkTop = Color(0xFF0E131C);
  static const Color dockSurfaceDarkMid = Color(0xFF090C13);
  static const Color dockSurfaceDarkBottom = Color(0xFF030508);
  static const Color cardCoverDarkTop = Color(0xFF101827);
  static const Color cardCoverDarkBottom = Color(0xFF070A10);
  static const Color cardCoverLightBottom = Color(0xFFF5F8FF);
  static const Color brandVividBlue = Color(0xFF1A55FF);
  static const Color isoBoxLightExteriorRight = Color(0xFFD8E1ED);
  static const Color isoBoxLightInteriorBackLeft = Color(0xFFB9C6D8);
  static const Color isoBoxLightInteriorBackRight = Color(0xFFA4B4CC);
  static const Color isoBoxLightInteriorFloor = Color(0xFF91A2BC);
  static const Color isoBoxLightFlapBackLeft = Color(0xFFE2E9F3);
  static const Color isoBoxLightFlapBackRight = Color(0xFFCBD6E6);
  static const Color isoBoxLightFlapFrontRight = Color(0xFFC6D3E4);
  static const Color isoBoxLightStrokeBox = Color(0x73B4C3D7);
  static const Color isoBoxLightStrokeTrail = Color(0xFFA4B3C8);
  static const Color isoBoxLightSparkle = Color(0xFFB8C5D8);
  static const Color isoBoxLightInsectBody = Color(0xFF59667A);
  static const Color isoBoxLightInsectWing = Color(0xBFC3D0E2);
  static const Color isoBoxDarkInteriorBackLeft = Color(0xFF0F1724);
  static const Color isoBoxDarkInteriorBackRight = Color(0xFF090E18);
  static const Color isoBoxDarkInteriorFloor = Color(0xFF060A12);
  static const Color isoBoxDarkFlapBackLeft = Color(0xFF1A2538);
  static const Color isoBoxDarkFlapBackRight = Color(0xFF121B2A);
  static const Color isoBoxDarkFlapFrontLeft = Color(0xFF172234);
  static const Color isoBoxDarkFlapFrontRight = Color(0xFF101929);
  static const Color cyanSubtle = Color(0xFFF0FDFA);
  static const Color skyDarkest = Color(0xFF0C4A6E);
  static const Color toolboxCavityBackLeft = Color(0xFF111827);
  static const Color toolboxCavityBackRight = Color(0xFF1F2937);
  static const Color toolboxCavityLeftTop = Color(0xFF2A303C);
  static const Color toolboxCavityLeftBottom = Color(0xFF141822);
  static const Color toolboxCavityRightTop = Color(0xFF374151);
  static const Color toolboxFaceLeftTop = Color(0xFFB3B3B3);
  static const Color toolboxFaceLeftBottom = Color(0xFF808080);
  static const Color toolboxFaceRightTop = Color(0xFFD9D9D9);
  static const Color toolboxFaceRightBottom = Color(0xFFA6A6A6);
  static const Color toolboxFaceTopEnd = Color(0xFFE8E8E8);
  static const Color toolboxSeamLight = Color(0xFFE6E6E6);
  static const Color toolboxSeamMid = Color(0xFFCCCCCC);
  static const Color toolboxSeamDark = Color(0xFF666666);
  static const Color toolboxCrossRed = Color(0xFFE60000);
  static const Color toolboxCrossShadow = Color(0xFF990000);
  static const Color toolboxHandleShadow = Color(0x66646464);
  static const Color toolboxHandleMount = Color(0xFF1A1A1A);
  static const Color toolboxHandle = Color(0xFF333333);
  static const Color toolboxHandleShimmer = Color(0xFF777777);
  static const Color toolboxLatchBase = Color(0xFF888888);
  static const Color toolboxLatchUpper = Color(0xFFDDDDDD);
  static const Color maskConcave40 = Color(0x40000000);
  static const Color maskConcaveA6 = Color(0xA6000000);
  static const Color maskConcaveEB = Color(0xEB000000);
  static const Color maskRadialBF = Color(0xBF000000);
  static const Color maskRadial73 = Color(0x73000000);
  static const Color maskRadial33 = Color(0x33000000);
  static const Color maskRadial0F = Color(0x0F000000);
  static const Color maskRadialCC = Color(0xCC000000);
  static const Color maskRadial80 = Color(0x80000000);
  static const Color maskRadial2B = Color(0x2B000000);
  static const Color maskLinearD9 = Color(0xD9000000);
  static const Color maskLinear59 = Color(0x59000000);
  static const Color carouselBgLightMid = Color(0xFFFAFBFF);
  static const Color carouselBgLightBottom = Color(0xFFF3F6FF);
  static const Color carouselRimStrokeLight = Color(0xF2E4EBFA);
  static const Color carouselRimStrokeDark = Color(0x1FFFFFFF);
  static const Color carouselDescriptionDark = Color(0xFFD4D4D8);
  static const Color carouselIndicatorInactiveDark = Color(0xFF3F3F46);
  static const Color carouselNavBtnBgLight = Color(0xF2FFFFFF);
  static const Color carouselNavBtnBorderLight = Color(0xE6E4E4E7);
  static const Color carouselNavBtnBgDark = Color(0xD90B0F16);
  static const Color carouselNavBtnBorderDark = Color(0x24FFFFFF);
  static const Color carouselShadowLight = Color(0x0A0A44FF);
  static const Color cardShadowDark = Color(0x80000000);
  static const Color scheduleBorderLight = Color(0xFFE4E4E7);
  static const Color scheduleBorderDark = Color(0x1FFFFFFF);
  static const Color scheduleDashedLight = Color(0xE6D4D4D8);
  static const Color scheduleDashedDark = Color(0x29FFFFFF);
  static const Color schedulePoliLight = Color(0xFF09090B);
  static const Color schedulePillBgDark = Color(0x14FFFFFF);
  static const Color scheduleDismissBgLight = Color(0xCCF4F4F5);
  static const Color scheduleGlassLight45 = Color(0xE6FFFFFF);
  static const Color scheduleGlassLight64 = Color(0x73FFFFFF);
  static const Color scheduleGlassLight82 = Color(0x1AFFFFFF);
  static const Color scheduleGlassLight100 = Color(0x00FFFFFF);
  static const Color scheduleGlassDark0 = Color(0xF505070B);
  static const Color scheduleGlassDark45 = Color(0xEB05070B);
  static const Color scheduleGlassDark64 = Color(0x990B0F16);
  static const Color scheduleGlassDark82 = Color(0x260B0F16);
  static const Color scheduleGlassDark100 = Color(0x000B0F16);
  static const Color scheduleSheenLight0 = Color(0x66FFFFFF);
  static const Color scheduleSheenLight35 = Color(0x26FFFFFF);
  static const Color scheduleSheenDark0 = Color(0x1AFFFFFF);
  static const Color scheduleSheenDark35 = Color(0x0A60A5FA);
  static const Color scheduleTransparent = Color(0x00000000);
  static const Color scheduleShadowLight = Color(0x0F000000);
}
