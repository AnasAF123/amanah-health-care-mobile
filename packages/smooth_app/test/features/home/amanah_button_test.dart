import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';

void main() {
  group('AmanahButton Master Component Tests', () {
    testWidgets('Renders primary bold button and handles tap event', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahButton.primary(
              text: 'Simpan Perubahan',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Simpan Perubahan'), findsOneWidget);
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('Renders secondary subtle button with leading icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahButton.secondary(
              text: 'Lihat Riwayat',
              leadingIcon: Icons.history_rounded,
            ),
          ),
        ),
      );

      expect(find.text('Lihat Riwayat'), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('Renders outline stroke button with trailing text badge', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahButton.outline(text: 'Filter', trailingText: '3'),
          ),
        ),
      );

      expect(find.text('Filter'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('Renders ghost transparent button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AmanahButton.ghost(text: 'Batal')),
        ),
      );

      expect(find.text('Batal'), findsOneWidget);
    });

    testWidgets('Renders text-only button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AmanahButton.text(text: 'Selengkapnya')),
        ),
      );

      expect(find.text('Selengkapnya'), findsOneWidget);
    });

    testWidgets('Renders circular icon-only action button', (
      WidgetTester tester,
    ) async {
      bool iconTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahButton.icon(
              icon: Icons.qr_code_2_rounded,
              onPressed: () => iconTapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
      await tester.pump();
      expect(iconTapped, isTrue);
    });

    testWidgets(
      'Renders loading spinner when isLoading is true and prevents tap',
      (WidgetTester tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AmanahButton.primary(
                text: 'Kirim',
                isLoading: true,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Kirim'), findsNothing);

        await tester.tap(find.byType(CircularProgressIndicator));
        await tester.pump();
        expect(tapped, isFalse);
      },
    );

    testWidgets('Disabled button does not trigger onPressed callback', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahButton.primary(
              text: 'Nonaktif',
              isDisabled: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Nonaktif'));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });
}
