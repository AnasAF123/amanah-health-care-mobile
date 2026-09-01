import 'package:flutter/material.dart';

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

  /// Backward-compatible blue aliases (purging cyan)
  static const Color cyan = Color(0xFF3B82F6);
  static const Color cyanLight = Color(0xFF60A5FA);
  static const Color cyanDark = Color(0xFF2563EB);

  /// --color-portal-emerald: #38c474 (Medical Success Emerald)
  static const Color emerald = Color(0xFF38C474);

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
  static const Color auroraCyanLight = Color(0xFF2563EB);
  static const Color auroraBlueLight = Color(0xFF2563EB);

  /// Dark Mode Aurora Primary Glow (Deep Cosmic Sapphire #07247A)
  static const Color auroraSapphireDark = Color(0xFF07247A);

  /// Dark Mode Aurora Secondary Glow (Royal Blue #1D4ED8)
  static const Color auroraCyanDark = Color(0xFF1D4ED8);
  static const Color auroraBlueDark = Color(0xFF1D4ED8);
}
