// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

const String APP_NAME = 'Amanah Healthcare';

const Widget EMPTY_WIDGET = SizedBox.shrink();

const double VERY_SMALL_SPACE = 4.0;
const double SMALL_SPACE = 8.0;
const double BALANCED_SPACE = 10.0;
const double MEDIUM_SPACE = 12.0;
const double LARGE_SPACE = 16.0;
const double VERY_LARGE_SPACE = 20.0;

/// Standard minimum touch/target size, cf. goldens.dart
const double MINIMUM_TOUCH_SIZE = kMinInteractiveDimension;

/// Default icon size, cf. [Icon]
const double DEFAULT_ICON_SIZE = 24.0;

/// Card background border radius
const Radius ROUNDED_RADIUS = Radius.circular(20.0);
//ignore: non_constant_identifier_names
const BorderRadius ROUNDED_BORDER_RADIUS = BorderRadius.all(ROUNDED_RADIUS);

/// Topbar…
const Radius HEADER_ROUNDED_RADIUS = Radius.circular(30.0);
//ignore: non_constant_identifier_names
const BorderRadius HEADER_BORDER_RADIUS = BorderRadius.all(
  HEADER_ROUNDED_RADIUS,
);

/// Full screen button, e.g. KnowledgePanel
const Radius ANGULAR_RADIUS = Radius.circular(8.0);
//ignore: non_constant_identifier_names
const BorderRadius ANGULAR_BORDER_RADIUS = BorderRadius.all(ANGULAR_RADIUS);

/// Buttons & TextFields
const Radius CIRCULAR_RADIUS = Radius.circular(40.0);
//ignore: non_constant_identifier_names
const BorderRadius CIRCULAR_BORDER_RADIUS = BorderRadius.all(CIRCULAR_RADIUS);

const BorderRadius MAX_BORDER_RADIUS = BorderRadius.all(Radius.circular(100.0));

/// Widget Colors
const Color WARNING_COLOR = AmanahColorTokens.warning;
const Color PRIMARY_BLUE_COLOR = AmanahColorTokens.brand;
const Color PRIMARY_GREY_COLOR = AmanahColorTokens.neutral700;
const Color FAIR_GREY_COLOR = AmanahColorTokens.neutral500;
const Color GREY_COLOR = AmanahColorTokens.neutral100;
const Color WHITE_COLOR = AmanahColorTokens.pureWhite;
const Color DARK_GREEN_COLOR = AmanahColorTokens.successDark;
const Color LIGHT_GREEN_COLOR = AmanahColorTokens.success;
const Color LIGHT_YELLOW_COLOR = AmanahColorTokens.amberLight;
const Color LIGHT_GREY_COLOR = AmanahColorTokens.neutral300;
const Color DARK_YELLOW_COLOR = AmanahColorTokens.amberDark;
const Color LIGHT_ORANGE_COLOR = AmanahColorTokens.warning;
const Color DARK_ORANGE_COLOR = AmanahColorTokens.warningDark;
const Color RED_COLOR = AmanahColorTokens.danger;
const Color LIGHT_RED_COLOR = AmanahColorTokens.dangerBorder;
const Color DARK_RED_COLOR = AmanahColorTokens.dangerDark;
const Color DARK_BROWN_COLOR = AmanahColorTokens.neutral950;

/// Widget Background Colors
const Color RED_BACKGROUND_COLOR = AmanahColorTokens.dangerSurface;
const Color ORANGE_BACKGROUND_COLOR = AmanahColorTokens.amberSurfaceLight;
const Color YELLOW_BACKGROUND_COLOR = AmanahColorTokens.warningSurface;
const Color LIGHT_GREEN_BACKGROUND_COLOR = AmanahColorTokens.successSurface;
const Color DARK_GREEN_BACKGROUND_COLOR = AmanahColorTokens.successBorder;
