import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_confetti_canvas.dart';

void main() {
  group('AmanahConfettiCanvas Widget Tests', () {
    testWidgets(
      'Renders and fires celebratory confetti particles without errors',
      (WidgetTester tester) async {
        final GlobalKey<AmanahConfettiCanvasState> confettiKey =
            GlobalKey<AmanahConfettiCanvasState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: AmanahConfettiCanvas(key: confettiKey),
                  ),
                ],
              ),
            ),
          ),
        );

        // Initially inactive
        expect(find.byType(AmanahConfettiCanvas), findsOneWidget);

        // Fire confetti
        confettiKey.currentState?.fire();
        await tester.pump();
        expect(find.byType(CustomPaint), findsWidgets);

        // Advance physics simulation through particles falling
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));

        expect(find.byType(AmanahConfettiCanvas), findsOneWidget);
      },
    );
  });
}
