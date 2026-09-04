import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_master_carousel_section.dart';

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

      // Verify active card content is rendered
      expect(find.byType(AmanahMasterCarouselSection), findsOneWidget);
      expect(find.text('Konsultasi Spesialis Anak'), findsOneWidget);
      expect(find.text('Jadwalkan'), findsOneWidget);

      // Verify navigation chevron buttons exist
      expect(find.byType(AmanahCarouselNavButton), findsNWidgets(2));

      // Verify indicator dots exist
      expect(find.byType(AmanahCarouselNotchedIndicator), findsOneWidget);
    });

    testWidgets('Tapping right chevron navigates cleanly to next slide index', (
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

      // Initially on slide 1
      expect(find.text('Konsultasi Spesialis Anak'), findsOneWidget);

      // Tap next chevron (right button)
      final Finder rightButton = find.byWidgetPredicate(
        (Widget w) => w is AmanahCarouselNavButton && !w.isLeft,
      );
      expect(rightButton, findsOneWidget);

      await tester.tap(rightButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Now on slide 2 (Vaksinasi & Booster Anak)
      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);
    });

    testWidgets('Preserves slide position when rebuilt (stay on position across page changes)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      // Initial build with Tab 0
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

      // Navigate to slide 2
      final Finder rightButton = find.byWidgetPredicate(
        (Widget w) => w is AmanahCarouselNavButton && !w.isLeft,
      );
      await tester.tap(rightButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);

      // Simulate switching to another page / tab
      setParentState(() => currentTab = 1);
      await tester.pumpAndSettle();
      expect(find.text('Other Page'), findsOneWidget);
      expect(find.byType(AmanahMasterCarouselSection), findsNothing);

      // Simulate switching back to Home page
      setParentState(() => currentTab = 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Carousel must stay on position (slide 2: Vaksinasi & Booster Anak), NOT glitch or reset to slide 1
      expect(find.text('Vaksinasi & Booster Anak'), findsOneWidget);
    });
  });
}
