import 'package:flutter/material.dart';
import 'package:smooth_app/helpers/collections_helper.dart';

const Color seed = Color(0xFF0F0A5A);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF0D66E9),
  inversePrimary: Color(0xFF2563EB),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFFEFF6FF),
  onSecondary: Color(0xFF0F172A),
  error: Color(0xFFEF4444),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF0F172A),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF0D66E9),
  inversePrimary: Color(0xFF38BDF8),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF0F1629),
  onSecondary: Color(0xFFCBD5E1),
  error: Color(0xFFF87171),
  onError: Color(0xFFFFFFFF),
  surface: Color(0xFF0B1329),
  onSurface: Color(0xFFFFFFFF),
);

const ColorScheme trueDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: COLOR_DEFAULT,
  inversePrimary: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF000000),
  secondary: COLOR_DEFAULT,
  onSecondary: Color(0xFFE1E1E1),
  error: Color(0xFFEA2B2B),
  onError: Color(0xFFE1E1E1),
  surface: Color(0xFF000000),
  onSurface: Color(0xFFFFFFFF),
);

const String CONTRAST_LOW = 'Low';
const String CONTRAST_MEDIUM = 'Medium';
const String CONTRAST_HIGH = 'High';

// All of the contrast Level passes WCAG 2.1 Results for text Readability.
const Color LOW_CONTRAST_TEXT_COLOR = Color(0xff969696);
const Color MEDIUM_CONTRAST_TEXT_COLOR = Color(0xffcacaca);
const Color HIGH_CONTRAST_TEXT_COLOR = Color(0xffffffff);

const Color Test = Colors.white10;

const String COLOR_DEFAULT_NAME = 'Default';
const Color COLOR_DEFAULT = Color(0xFF0F0A5A);
const Color COLOR_BLUE = Colors.blue;
const Color COLOR_CYAN = Color(0xff0097a7);
const Color COLOR_GREEN = Color(0xff009b52);
const Color COLOR_MAGENTA = Color(0xffff00ff);
const Color COLOR_ORANGE = Colors.deepOrange;
const Color COLOR_PINK = Colors.pink;
const Color COLOR_RED = Color(0xffff0000);
const Color COLOR_RUST = Color(0xffb7410e);
const Color COLOR_TEAL = Colors.teal;

const Map<String, Color> colorNamesValue = <String, Color>{
  'Default': COLOR_DEFAULT,
  'Blue': COLOR_BLUE,
  'Cyan': COLOR_CYAN,
  'Green': COLOR_GREEN,
  'Magenta': COLOR_MAGENTA,
  'Orange': COLOR_ORANGE,
  'Pink': COLOR_PINK,
  'Red': COLOR_RED,
  'Rust': COLOR_RUST,
  'Teal': COLOR_TEAL,
};

/// Get Color from Color Name using colorNamesValue
Color getColorValue(String colorName) {
  if (colorNamesValue.containsKey(colorName)) {
    return colorNamesValue.getValueByKeyStartWith(colorName)!;
  }
  return COLOR_DEFAULT;
}

Color getTextContrastLevel(String contrastLevel) {
  switch (contrastLevel) {
    case CONTRAST_LOW:
      return LOW_CONTRAST_TEXT_COLOR;

    case CONTRAST_MEDIUM:
      return MEDIUM_CONTRAST_TEXT_COLOR;

    case CONTRAST_HIGH:
      return HIGH_CONTRAST_TEXT_COLOR;

    default:
      return HIGH_CONTRAST_TEXT_COLOR;
  }
}
