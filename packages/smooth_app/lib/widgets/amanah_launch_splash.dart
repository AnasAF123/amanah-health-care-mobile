import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AmanahLaunchSplash extends StatelessWidget {
  const AmanahLaunchSplash({super.key});

  static const Color _primaryNavy = Color(0xFF0F0A5A);
  static const Color _darkSurface = Color(0xFF0F172A);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const String _logoPath = 'assets/amanah/launch_logo.png';
  static const double _nativeSplashLogoSize = 288;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? _darkSurface : _lightSurface;
    final Color foreground = isDark ? Colors.white : _primaryNavy;
    final Color secondary = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryNavy,
          brightness: brightness,
        ),
      ),
      home: Scaffold(
        backgroundColor: background,
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                _logoPath,
                width: _nativeSplashLogoSize,
                height: _nativeSplashLogoSize,
                fit: BoxFit.contain,
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
                        builder:
                            (
                              BuildContext context,
                              AsyncSnapshot<PackageInfo> snapshot,
                            ) {
                              final String version =
                                  snapshot.data?.version ?? '';
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
                        color: foreground,
                        backgroundColor: foreground.withValues(alpha: 0.10),
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
