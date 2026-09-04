import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahLaunchSplash extends StatelessWidget {
  const AmanahLaunchSplash({super.key});

  static const String _emblemPath = 'assets/amanah/launch_emblem.png';
  static const double _emblemSize = 104;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;
    final Color background =
        isDark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;
    final Color foreground =
        isDark ? Colors.white : const Color(0xFF13195C);
    final Color secondary =
        isDark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral600;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        brightness: brightness,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AmanahColorTokens.brand,
          brightness: brightness,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: foreground),
          bodySmall: TextStyle(color: secondary),
        ),
      ),
      home: Scaffold(
        backgroundColor: background,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    _emblemPath,
                    width: _emblemSize,
                    height: _emblemSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amanah',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                top: false,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 28,
                      child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<PackageInfo> snapshot,
                        ) {
                          final String version = snapshot.data?.version ?? '';
                          final String text = version.isEmpty
                              ? 'Powered by Amikom'
                              : 'Powered by Amikom v$version';

                          return Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 58,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(999),
                        color: AmanahColorTokens.brand,
                        backgroundColor: AmanahColorTokens.brand.withValues(
                          alpha: isDark ? 0.20 : 0.12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
