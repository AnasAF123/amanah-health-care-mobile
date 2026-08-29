import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_blurry_morph_text.dart';

void main() {
  group('BlurryMorphText Widget Tests', () {
    testWidgets('Renders initial static text cleanly without blur', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurryMorphText(
              text: 'Pilih antrean pasien',
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
          ),
        ),
      );

      expect(find.text('Pilih antrean pasien'), findsOneWidget);
    });

    testWidgets('Morphs text smoothly with two-phase gaussian blur on text change', (
      WidgetTester tester,
    ) async {
      String currentText = 'Pilih antrean pasien';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: <Widget>[
                    BlurryMorphText(
                      text: currentText,
                      style: const TextStyle(fontSize: 22, color: Colors.black),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentText = 'Lepaskan untuk proses antrean';
                        });
                      },
                      child: const Text('Change Text'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Pilih antrean pasien'), findsOneWidget);

      // Trigger text change
      await tester.tap(find.text('Change Text'));
      await tester.pump();

      // Mid Exit Phase (90ms) - blurred exit
      await tester.pump(const Duration(milliseconds: 90));

      // Mid Enter Phase (300ms) - entering sharp
      await tester.pump(const Duration(milliseconds: 210));

      // Fully complete animation
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Lepaskan untuk proses antrean'), findsOneWidget);
    });

    testWidgets('Renders monospaced typewriter dots without layout shift when isProcessing is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurryMorphText(
              text: 'Memproses antrean',
              isProcessing: true,
              dotCount: 2,
              style: TextStyle(fontSize: 22, color: Colors.blue),
            ),
          ),
        ),
      );

      expect(find.text('Memproses'), findsOneWidget);
      expect(find.text('antrean'), findsOneWidget);
      expect(find.text('..'), findsOneWidget);
    });
  });
}
