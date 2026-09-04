import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/widgets/amanah_launch_splash.dart';

void main() {
  group('AmanahLaunchSplash Widget Tests', () {
    testWidgets('Renders emblem, dynamic font text, and progress in Light mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.light),
          child: AmanahLaunchSplash(),
        ),
      );
      await tester.pump();

      // Find emblem image
      expect(find.byType(Image), findsOneWidget);

      // Find "Amanah" text and verify styling in light mode
      final Finder textFinder = find.text('Amanah');
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontFamily, 'PlusJakartaSans');
      expect(textWidget.style?.fontSize, 32);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
      expect(textWidget.style?.color, const Color(0xFF13195C));

      // Scaffold background in light mode
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AmanahColorTokens.canvasLight);
    });

    testWidgets('Renders white dynamic font text matching Dark theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(platformBrightness: Brightness.dark),
          child: AmanahLaunchSplash(),
        ),
      );
      await tester.pump();

      // Find emblem image
      expect(find.byType(Image), findsOneWidget);

      // Find "Amanah" text and verify styling in dark mode
      final Finder textFinder = find.text('Amanah');
      expect(textFinder, findsOneWidget);

      final Text textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.fontFamily, 'PlusJakartaSans');
      expect(textWidget.style?.fontSize, 32);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
      expect(textWidget.style?.color, Colors.white);

      // Scaffold background in dark mode
      final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, AmanahColorTokens.canvasDark);
    });
  });
}
