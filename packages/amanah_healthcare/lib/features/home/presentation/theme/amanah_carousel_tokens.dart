import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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

  static const LinearGradient cardBgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AmanahColorTokens.pureWhite,
      AmanahColorTokens.carouselBgLightMid,
      AmanahColorTokens.carouselBgLightBottom,
    ],
  );

  static const LinearGradient cardBgDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      AmanahColorTokens.surfaceDark,
      AmanahColorTokens.surfaceSecondaryDark,
      AmanahColorTokens.surfaceElevatedDark,
    ],
  );

  static const Color rimStrokeColor = AmanahColorTokens.carouselRimStrokeLight;
  static const Color rimStrokeDarkColor = AmanahColorTokens.carouselRimStrokeDark;
  static const double rimStrokeWidth = 1.5;

  static const Color titleColor = AmanahColorTokens.neutral900;
  static const Color titleDarkColor = AmanahColorTokens.pureWhite;
  static const Color descriptionColor = AmanahColorTokens.neutral600;
  static const Color descriptionDarkColor = AmanahColorTokens.carouselDescriptionDark;

  static const LinearGradient btnBlueGradient = AmanahColorTokens.btnCrispBlueGradient;
  static const LinearGradient btnBlueDarkGradient = AmanahColorTokens.btnCrispBlueDarkGradient;
  static const Color btnBlueBorder = AmanahColorTokens.btnCrispBlueBorder;
  static const Color btnBlueTextColor = AmanahColorTokens.pureWhite;
  static const Color btnBlueIconColor = AmanahColorTokens.pureWhite;
  static const double btnBorderWidth = 1.0;
  static const double btnRadius = 12.0;

  static const Color indicatorActiveColor = AmanahColorTokens.brand;
  static const Color indicatorActiveDarkColor = AmanahColorTokens.skySoft;
  static const Color indicatorInactiveColor = AmanahColorTokens.neutral300;
  static const Color indicatorInactiveDarkColor = AmanahColorTokens.carouselIndicatorInactiveDark;
  static const double indicatorHeight = 6.0;
  static const double indicatorActiveWidth = 20.0;
  static const double indicatorInactiveWidth = 6.0;

  static const Color navBtnBg = AmanahColorTokens.carouselNavBtnBgLight;
  static const Color navBtnBorder = AmanahColorTokens.carouselNavBtnBorderLight;
  static const Color navBtnIconColor = AmanahColorTokens.neutral700;
  static const Color navBtnDarkBg = AmanahColorTokens.carouselNavBtnBgDark;
  static const Color navBtnDarkBorder = AmanahColorTokens.carouselNavBtnBorderDark;
  static const Color navBtnDarkIconColor = AmanahColorTokens.pureWhite;
  static const double navBtnSize = 30.0;

  static const List<BoxShadow> cardShadow = <BoxShadow>[
    BoxShadow(
      color: AmanahColorTokens.carouselShadowLight,
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> cardShadowDark = <BoxShadow>[
    BoxShadow(
      color: AmanahColorTokens.cardShadowDark,
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];
}
