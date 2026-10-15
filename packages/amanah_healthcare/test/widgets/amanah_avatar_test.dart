import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/user_avatar.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

void main() {
  group('AmanahAvatar Widget Tests', () {
    testWidgets('Renders CircleAvatar with initials when type is initials', (
      WidgetTester tester,
    ) async {
      const UserAvatar avatar = UserAvatar(
        url: '',
        initials: 'AS',
        type: 'initials',
        hasCustomAvatar: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahAvatar(
              avatar: avatar,
              radius: 30,
            ),
          ),
        ),
      );

      expect(find.text('AS'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('Renders fallback initials AH when initials string is empty', (
      WidgetTester tester,
    ) async {
      const UserAvatar avatar = UserAvatar(
        url: '',
        initials: '',
        type: 'initials',
        hasCustomAvatar: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahAvatar(
              avatar: avatar,
            ),
          ),
        ),
      );

      expect(find.text('AH'), findsOneWidget);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      const UserAvatar avatar = UserAvatar(
        url: '',
        initials: 'DS',
        type: 'initials',
        hasCustomAvatar: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahAvatar(
              avatar: avatar,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('DS'), findsOneWidget);
    });

    testWidgets('Calls onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;
      const UserAvatar avatar = UserAvatar(
        url: '',
        initials: 'AS',
        type: 'initials',
        hasCustomAvatar: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahAvatar(
              avatar: avatar,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AmanahAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('Renders Semantics node when semanticsLabel is provided', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        const UserAvatar avatar = UserAvatar(
          url: '',
          initials: 'AS',
          type: 'initials',
          hasCustomAvatar: false,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: AmanahAvatar(
                avatar: avatar,
                semanticsLabel: 'Foto Profil Dokter',
              ),
            ),
          ),
        );

        expect(
          find.byWidgetPredicate(
            (Widget w) =>
                w is Semantics && w.properties.label == 'Foto Profil Dokter',
          ),
          findsOneWidget,
        );
      } finally {
        handle.dispose();
      }
    });
  });
}
