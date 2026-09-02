import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Design tokens for the Master Clipping-Path Deck Carousel on Home Screen (Light Theme baseline)
/// Extracted 1:1 from MasterCarouselSection.tsx and global.css (.web)
abstract final class AmanahCarouselTokens {
  // --- Dimensions & Timing ---
  static const double stageHeight = 158.0;
  static const double cardHeight = 154.0;
  static const int autoplayDelayMs = 3800;
  static const double touchSwipeThresholdPx = 30.0;

  // --- Geometry & Inward Notch Ratios (ObjectBoundingBox normalized) ---
  // Inward concave cavity between x=0.33 and x=0.67 receding up to y=0.86
  static const double notchStartRatioX = 0.33;
  static const double notchLeftTopRatioX = 0.415;
  static const double notchRightTopRatioX = 0.585;
  static const double notchEndRatioX = 0.67;
  static const double notchDepthRatioY = 0.86;
  static const double cornerRadiusRatio = 0.07;
  static const double cornerVerticalRadiusRatio = 0.16;

  // --- 3D Deck Scaling & Stacking ---
  static const double frontScale = 1.0;
  static const double sideScale = 0.88;
  static const double hiddenScale = 0.70;

  static const double sideXPercent = 64.0;
  static const double hiddenXPercent = 130.0;

  static const double sideZ = -100.0;
  static const double hiddenZ = -220.0;

  // Blur on Side Cards (1:1 with CSS filter: blur(1.5px))
  static const double sideBlurSigma = 1.5;

  // --- Light Theme Colors ---
  static const LinearGradient cardBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFFFFFFF),
      Color(0xFFF4F7FF),
      Color(0xFFEAF0FF),
    ],
  );

  static const Color rimStrokeColor = Color(0xF2DBEAFE); // rgba(219,234,254,0.95)
  static const double rimStrokeWidth = 1.5;

  static const Color titleColor = Color(0xFF0F172A); // text-slate-900 (font-black)
  static const Color descriptionColor = Color(0xFF475569); // text-slate-600 (font-medium)

  // --- Action Button (.btn-crisp-blue) 1:1 Gradient with Specular Sheen ---
  static const LinearGradient btnBlueGradient = AmanahColorTokens.btnCrispBlueGradient;
  static const LinearGradient btnBlueDarkGradient = AmanahColorTokens.btnCrispBlueDarkGradient;
  static const Color btnBlueBorder = AmanahColorTokens.btnCrispBlueBorder;
  static const Color btnBlueTextColor = Colors.white;
  static const Color btnBlueIconColor = Colors.white;
  static const double btnBorderWidth = 1.0;
  static const double btnRadius = 12.0;

  // --- Indicators (Docked inside Inward Cavity Notch) ---
  static const Color indicatorActiveColor = AmanahColorTokens.brand;
  static const Color indicatorInactiveColor = Color(0xFFCBD5E1);
  static const double indicatorHeight = 6.0;
  static const double indicatorActiveWidth = 20.0;
  static const double indicatorInactiveWidth = 6.0;

  // --- Navigator Chevron Buttons ---
  static const Color navBtnBg = Color(0xF2FFFFFF); // bg-white/95
  static const Color navBtnBorder = Color(0xE6DBEAFE); // border-blue-100/90
  static const Color navBtnIconColor = Color(0xFF334155); // text-slate-700
  static const double navBtnSize = 30.0;

  // --- Card Shadows ---
  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F0A44FF), // shadow-[0_8px_28px_rgba(10,68,255,0.06)]
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];
}
