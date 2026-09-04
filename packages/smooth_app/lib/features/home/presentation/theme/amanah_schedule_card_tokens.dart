import 'package:flutter/material.dart';

/// Design tokens for the Doctor Schedule Card on Home Screen (Light & Dark Themes)
/// Extracted 1:1 from ScheduleCard.tsx and global.css (.web)
abstract final class AmanahScheduleCardTokens {
  // --- Dimensions & Geometry ---
  static const double cardHeight = 172.0;
  static const double stackHeight = 196.0;
  static const double cornerRadius = 24.0;
  static const double notchRadius = 11.0;
  static const double notchCenterY = 114.0;
  static const double notchStartY = 103.0;
  static const double notchEndY = 125.0;
  static const EdgeInsets padding = EdgeInsets.all(18.0);

  // --- Base Colors ---
  static const Color cardBgLight = Color(0xFFFFFFFF);
  static const Color cardBgDark = Color(0xFF060B18);

  static const Color borderStrokeLight = Color(0xF2E2E8F0); // rgba(226, 232, 240, 0.95)
  static const Color borderStrokeDark = Color(0x29FFFFFF); // rgba(255, 255, 255, 0.16)
  static const double borderWidth = 1.2;

  static const Color dashedLineColorLight = Color(0xE6CBD5E1); // rgba(203, 213, 225, 0.90)
  static const Color dashedLineColorDark = Color(0x33FFFFFF); // rgba(255, 255, 255, 0.20)
  static const double dashedLineWidth = 1.5;

  static const Color titleColorLight = Color(0xFF0F172A); // text-slate-900
  static const Color titleColorDark = Colors.white;

  static const Color dateColorLight = Color(0xFF64748B); // text-[#64748b]
  static const Color dateColorDark = Color(0xFFCBD5E1); // text-slate-300 from .web

  static const Color timeColorLight = Color(0xFF0F172A); // text-slate-900
  static const Color timeColorDark = Colors.white;

  static const Color poliColorLight = Color(0xFF0F172B); // text-[#0f172b]
  static const Color poliColorDark = Color(0xFFE2E8F0);

  static const Color roomColorLight = Color(0xFF64748B); // text-[#64748b]
  static const Color roomColorDark = Color(0xFFCBD5E1); // text-slate-300 from .web

  static const Color bookingPillBgLight = Color(0xFFF1F5F9); // bg-slate-100
  static const Color bookingPillBgDark = Color(0x1AFFFFFF); // bg-white/10 from .web

  static const Color bookingPillTextLight = Color(0xFF0F172B); // text-[#0f172b]
  static const Color bookingPillTextDark = Colors.white;

  static const Color dismissBtnBgLight = Color(0xCCF1F5F9); // bg-slate-100/80
  static const Color dismissBtnBgDark = Color(0x1AFFFFFF); // bg-white/10 from .web

  static const Color dismissBtnIconColorLight = Color(0xFF64748B); // text-slate-500
  static const Color dismissBtnIconColorDark = Color(0xFFCBD5E1);

  // --- Gradients ---
  /// Seamless horizontal Liquid Glass Gradient Mask (Light Theme)
  static const LinearGradient liquidGlassGradientLight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: <double>[0.0, 0.45, 0.64, 0.82, 1.0],
    colors: <Color>[
      Color(0xF2FFFFFF), // 0%: 0.95 opacity
      Color(0xE6FFFFFF), // 45%: 0.90 opacity
      Color(0x73FFFFFF), // 64%: 0.45 opacity
      Color(0x1AFFFFFF), // 82%: 0.10 opacity
      Color(0x00FFFFFF), // 100%: 0.00 opacity
    ],
  );

  /// Seamless horizontal Liquid Glass Gradient Mask (Dark Theme)
  static const LinearGradient liquidGlassGradientDark = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: <double>[0.0, 0.45, 0.64, 0.82, 1.0],
    colors: <Color>[
      Color(0xF5060B18), // 0%: 0.96 opacity
      Color(0xEB060B18), // 45%: 0.92 opacity
      Color(0x990B1329), // 64%: 0.60 opacity
      Color(0x260B1329), // 82%: 0.15 opacity
      Color(0x000B1329), // 100%: 0.00 opacity
    ],
  );

  /// Top-to-bottom Specular Glass Sheen Overlay (Light Theme)
  static const LinearGradient glassSpecularSheenLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.35, 1.0],
    colors: <Color>[
      Color(0x66FFFFFF), // 0%: 0.40 opacity
      Color(0x26FFFFFF), // 35%: 0.15 opacity
      Color(0x00FFFFFF), // 100%: 0.00 opacity
    ],
  );

  /// Top-to-bottom Specular Glass Sheen Overlay (Dark Theme)
  static const LinearGradient glassSpecularSheenDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.35, 1.0],
    colors: <Color>[
      Color(0x1FFFFFFF), // 0%: 0.12 opacity
      Color(0x0A38BDF8), // 35%: 0.04 opacity sky-400 sheen from .web
      Color(0x00000000), // 100%: 0.00 opacity
    ],
  );

  // --- Shadow ---
  static const List<BoxShadow> cardShadowLight = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000), // drop-shadow-[0_12px_28px_rgba(0,0,0,0.06)]
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> cardShadowDark = <BoxShadow>[
    BoxShadow(
      color: Color(0x66000000), // drop-shadow-[0_14px_32px_rgba(0,0,0,0.40)]
      blurRadius: 32,
      offset: Offset(0, 14),
    ),
  ];

  // --- Assets ---
  static const String bgImageLight =
      'assets/amanah/images/home-schedule-card-bg-light.png';
  static const String bgImageDark =
      'assets/amanah/images/home-schedule-card-bg-dark.png';
}
