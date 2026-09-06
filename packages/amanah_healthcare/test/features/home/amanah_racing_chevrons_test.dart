import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_racing_chevrons.dart';

void main() {
  group('AmanahRacingPulseChevrons Widget Tests', () {
    testWidgets('Renders racing chevrons and repeats kinetic pulse animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AmanahRacingPulseChevrons())),
        ),
      );

      expect(find.byType(AmanahRacingPulseChevrons), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance animation through pulse wave cycles
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AmanahRacingPulseChevrons), findsOneWidget);
    });

    testWidgets('Renders properly under dark theme with tabActiveDark gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Center(child: AmanahRacingPulseChevrons(isDark: true)),
          ),
        ),
      );

      expect(find.byType(AmanahRacingPulseChevrons), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Renders properly under light theme with brand gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: Center(child: AmanahRacingPulseChevrons(isDark: false)),
          ),
        ),
      );

      expect(find.byType(AmanahRacingPulseChevrons), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('AmanahChevronRenderer Master Tests', () {
    test('Builds single chevron vector path correctly', () {
      final Path path = AmanahChevronRenderer.buildChevronPath(
        centerX: 50.0,
        yOffset: 20.0,
        scale: 1.0,
      );
      expect(path, isNotNull);
      expect(path.getBounds().isEmpty, isFalse);
    });
  });
}
