import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_racing_chevrons.dart';

void main() {
  group('AmanahRacingPulseChevrons Widget Tests', () {
    testWidgets('Renders racing chevrons and repeats kinetic pulse animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AmanahRacingPulseChevrons(),
            ),
          ),
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
  });
}
