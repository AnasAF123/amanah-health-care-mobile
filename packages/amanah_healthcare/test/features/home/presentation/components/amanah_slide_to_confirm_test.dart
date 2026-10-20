import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';

void main() {
  group('AmanahSlideToConfirm Widget Tests', () {
    testWidgets('Renders idle state with prompt text and chevrons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: AmanahSlideToConfirm(
                  text: 'Geser untuk Ambil Jadwal',
                  onConfirmed: () async {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Geser untuk Ambil Jadwal'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('Triggers onConfirmed callback on horizontal drag threshold', (WidgetTester tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                child: AmanahSlideToConfirm(
                  text: 'Geser untuk Ambil Jadwal',
                  completedText: 'Berhasil Diambil!',
                  onConfirmed: () async {
                    confirmed = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(confirmed, isFalse);

      // Drag the knob to the right
      final Finder knobFinder = find.byIcon(Icons.arrow_forward_rounded);
      await tester.drag(knobFinder, const Offset(300, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(confirmed, isTrue);
      expect(find.text('Berhasil Diambil!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
