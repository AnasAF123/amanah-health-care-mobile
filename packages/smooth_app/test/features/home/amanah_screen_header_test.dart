import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_doctor_id_card_components.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';

void main() {
  group('AmanahScreenHeader Tests', () {
    testWidgets(
      'AmanahDoctorIdCardHeader title is exactly horizontally centered on screen',
      (WidgetTester tester) async {
        const double screenWidth = 600.0;
        tester.view.physicalSize = const Size(screenWidth * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AmanahDoctorIdCardHeader(
                    onBack: () {},
                    onInfo: () {},
                    onQr: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder titleFinder = find.text('Kartu Identitas');
        expect(titleFinder, findsOneWidget);

        final Offset center = tester.getCenter(titleFinder);
        // Middle of 600px screen is 300px
        expect(center.dx, closeTo(screenWidth / 2, 0.5));
      },
    );

    testWidgets(
      'AmanahScreenHeader.standard title is horizontally centered',
      (WidgetTester tester) async {
        const double screenWidth = 600.0;
        tester.view.physicalSize = const Size(screenWidth * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AmanahScreenHeader.standard(
                    title: 'Jadwal Praktik',
                    onBack: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder titleFinder = find.text('Jadwal Praktik');
        expect(titleFinder, findsOneWidget);

        final Offset center = tester.getCenter(titleFinder);
        expect(center.dx, closeTo(screenWidth / 2, 0.5));
      },
    );

    testWidgets(
      'AmanahScreenHeader.startAligned title starts after leading icon',
      (WidgetTester tester) async {
        const double screenWidth = 600.0;
        tester.view.physicalSize = const Size(screenWidth * 2, 800 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: <Widget>[
                  AmanahScreenHeader.startAligned(
                    title: 'Perizinan Dokter',
                    onBack: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder titleFinder = find.text('Perizinan Dokter');
        expect(titleFinder, findsOneWidget);

        final Rect titleRect = tester.getRect(titleFinder);
        final Rect leadingRect = tester.getRect(find.byIcon(Icons.arrow_back_rounded));

        // Start aligned title begins to the right of the leading back button
        expect(titleRect.left, greaterThan(leadingRect.right));
        expect(titleRect.center.dx, lessThan(screenWidth / 2));
      },
    );
  });
}
