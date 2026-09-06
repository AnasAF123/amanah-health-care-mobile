import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_sheet_container.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';

void main() {
  group('AuthSheetContainer Dynamic Hugging & Keyboard Lift Tests', () {
    testWidgets(
      'Hugs content dynamically and lifts via AnimatedPadding on keyboard popup',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.reset());

        // 1. Without keyboard
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: AuthSheetContainer(
                child: SizedBox(
                  height: 250,
                  child: Text('Short content'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder containerFinder = find.byType(AuthSheetContainer);
        expect(containerFinder, findsOneWidget);

        final AnimatedPadding animatedPaddingInitial = tester.widget<AnimatedPadding>(
          find.byType(AnimatedPadding),
        );
        expect(animatedPaddingInitial.padding, equals(EdgeInsets.zero));

        // 2. Simulate keyboard popping up with 300px viewInsets
        tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 2);
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: AuthSheetContainer(
                child: SizedBox(
                  height: 250,
                  child: Text('Short content'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final AnimatedPadding animatedPaddingWithKeyboard = tester.widget<AnimatedPadding>(
          find.byType(AnimatedPadding),
        );
        // The container is pushed up smoothly by bottomInset
        expect(animatedPaddingWithKeyboard.padding, equals(const EdgeInsets.only(bottom: 300.0)));

        // Verify AmanahSheetHandle is rendered at top of drawer
        expect(find.byType(AmanahSheetHandle), findsOneWidget);

        // Verify scrollbars are disabled inside AuthSheetContainer
        final ScrollConfiguration scrollConfig = tester.widget<ScrollConfiguration>(
          find.descendant(
            of: find.byType(AuthSheetContainer),
            matching: find.byType(ScrollConfiguration),
          ),
        );
        final ScrollBehavior behavior = scrollConfig.behavior;
        expect(behavior.buildScrollbar(tester.element(find.byType(SingleChildScrollView)), const SizedBox(), ScrollableDetails.vertical()), isA<SizedBox>());
      },
    );
  });
}
