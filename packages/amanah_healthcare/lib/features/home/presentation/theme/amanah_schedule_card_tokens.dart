import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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

  static const Color cardBgLight = AmanahColorTokens.pureWhite;
  static const Color cardBgDark = AmanahColorTokens.brandNavyDark;

  static const Color borderStrokeLight = AmanahColorTokens.scheduleBorderLight;
  static const Color borderStrokeDark = AmanahColorTokens.scheduleBorderDark;
  static const double borderWidth = 1.2;

  static const Color dashedLineColorLight = AmanahColorTokens.scheduleDashedLight;
  static const Color dashedLineColorDark = AmanahColorTokens.scheduleDashedDark;
  static const double dashedLineWidth = 1.5;

  static const Color titleColorLight = AmanahColorTokens.neutral900;
  static const Color titleColorDark = AmanahColorTokens.pureWhite;

  static const Color dateColorLight = AmanahColorTokens.neutral500;
  static const Color dateColorDark = AmanahColorTokens.neutral300;

  static const Color timeColorLight = AmanahColorTokens.neutral900;
  static const Color timeColorDark = AmanahColorTokens.pureWhite;

  static const Color poliColorLight = AmanahColorTokens.schedulePoliLight;
  static const Color poliColorDark = AmanahColorTokens.neutral200;

  static const Color roomColorLight = AmanahColorTokens.neutral500;
  static const Color roomColorDark = AmanahColorTokens.neutral300;

  static const Color bookingPillBgLight = AmanahColorTokens.neutral100;
  static const Color bookingPillBgDark = AmanahColorTokens.schedulePillBgDark;

  static const Color bookingPillTextLight = AmanahColorTokens.schedulePoliLight;
  static const Color bookingPillTextDark = AmanahColorTokens.pureWhite;

  static const Color dismissBtnBgLight = AmanahColorTokens.scheduleDismissBgLight;
  static const Color dismissBtnBgDark = AmanahColorTokens.schedulePillBgDark;

  static const Color dismissBtnIconColorLight = AmanahColorTokens.neutral500;
  static const Color dismissBtnIconColorDark = AmanahColorTokens.neutral300;

  static const LinearGradient liquidGlassGradientLight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: <double>[0.0, 0.45, 0.64, 0.82, 1.0],
    colors: <Color>[
      AmanahColorTokens.carouselNavBtnBgLight,
      AmanahColorTokens.scheduleGlassLight45,
      AmanahColorTokens.scheduleGlassLight64,
      AmanahColorTokens.scheduleGlassLight82,
      AmanahColorTokens.scheduleGlassLight100,
    ],
  );

  static const LinearGradient liquidGlassGradientDark = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: <double>[0.0, 0.45, 0.64, 0.82, 1.0],
    colors: <Color>[
      AmanahColorTokens.scheduleGlassDark0,
      AmanahColorTokens.scheduleGlassDark45,
      AmanahColorTokens.scheduleGlassDark64,
      AmanahColorTokens.scheduleGlassDark82,
      AmanahColorTokens.scheduleGlassDark100,
    ],
  );

  static const LinearGradient glassSpecularSheenLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.35, 1.0],
    colors: <Color>[
      AmanahColorTokens.scheduleSheenLight0,
      AmanahColorTokens.scheduleSheenLight35,
      AmanahColorTokens.scheduleGlassLight100,
    ],
  );

  static const LinearGradient glassSpecularSheenDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0.0, 0.35, 1.0],
    colors: <Color>[
      AmanahColorTokens.scheduleSheenDark0,
      AmanahColorTokens.scheduleSheenDark35,
      AmanahColorTokens.scheduleTransparent,
    ],
  );

  static const List<BoxShadow> cardShadowLight = <BoxShadow>[
    BoxShadow(
      color: AmanahColorTokens.scheduleShadowLight,
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> cardShadowDark = <BoxShadow>[
    BoxShadow(
      color: AmanahColorTokens.cardShadowDark,
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
