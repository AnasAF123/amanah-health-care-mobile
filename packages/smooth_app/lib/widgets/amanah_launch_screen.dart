import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/widgets/amanah_brand_logo.dart';

/// Pure Launch Screen for Amanah Healthcare (Initial Stage before booting).
/// Uses the single-source-of-truth AmanahBrandLogo component.
class AmanahLaunchScreen extends StatelessWidget {
  const AmanahLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;
    final Color background =
        isDark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;

    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: AmanahBrandLogo(isDark: isDark),
      ),
    );
  }
}
