import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_master_carousel_section.dart';

void main() {
  group('AmanahMasterCarouselSection Tests', () {
    testWidgets('Renders master carousel section and active slide card in light and dark mode', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahMasterCarouselSection(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AmanahMasterCarouselSection), findsOneWidget);
      expect(find.text('Konsultasi Spesialis Anak'), findsOneWidget);
      expect(find.text('Jadwalkan'), findsOneWidget);
      expect(find.byType(AmanahCarouselNotchedIndicator), findsOneWidget);
    });

    testWidgets('Swiping left navigates cleanly to next slide index', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahMasterCarouselSection(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Konsultasi Spesialis Anak'), findsOneWidget);

      await tester.drag(
        find.byType(AmanahMasterCarouselSection),
        const Offset(-400, 0),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);
    });

    testWidgets('Preserves slide position when rebuilt (stay on position across page changes)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      int currentTab = 0;
      late StateSetter setParentState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setParentState = setState;
            return MaterialApp(
              home: Scaffold(
                body: currentTab == 0
                    ? const AmanahMasterCarouselSection()
                    : const Center(child: Text('Other Page')),
              ),
            );
          },
        ),
      );
      await tester.pump();

      await tester.drag(
        find.byType(AmanahMasterCarouselSection),
        const Offset(-400, 0),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);

      setParentState(() => currentTab = 1);
      await tester.pumpAndSettle();
      expect(find.text('Other Page'), findsOneWidget);
      expect(find.byType(AmanahMasterCarouselSection), findsNothing);

      setParentState(() => currentTab = 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);
    });
  });
}
