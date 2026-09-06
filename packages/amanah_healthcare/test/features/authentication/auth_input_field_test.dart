import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/account_switch_action.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/password_input_field.dart';

void main() {
  group('AuthInputField and PasswordInputField ScrollPadding Tests', () {
    testWidgets('AuthInputField defaults to 120.0 bottom scrollPadding', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthInputField(
              label: 'Nama Lengkap',
              hintText: 'Masukkan nama',
              leadingIcon: Icons.person_outline_rounded,
              controller: controller,
            ),
          ),
        ),
      );

      final TextField textField = tester.widget<TextField>(
        find.byType(TextField),
      );
      expect(textField.scrollPadding, equals(const EdgeInsets.only(bottom: 120.0)));
    });

    testWidgets(
      'PasswordInputField passes 120.0 bottom scrollPadding down to TextField',
      (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PasswordInputField(
                label: 'Konfirmasi Password',
                hintText: 'Konfirmasi password',
                controller: controller,
              ),
            ),
          ),
        );

        final TextField textField = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(
          textField.scrollPadding,
          equals(const EdgeInsets.only(bottom: 120.0)),
        );
      },
    );

    testWidgets(
      'AuthInputField morphs IFTA label inside container frame and slides leading icon into left wall when focused',
      (WidgetTester tester) async {
        final TextEditingController controller = TextEditingController();
        final FocusNode focusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthInputField(
                label: 'Nama Lengkap',
                hintText: 'Masukkan nama',
                leadingIcon: Icons.person_outline_rounded,
                controller: controller,
                focusNode: focusNode,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial state: unfocused and empty
        // - Icon is visible at left: 16.0
        // - Label is at left: 48.0, top: 19.0
        // - TextField is at left: 48.0
        AnimatedPositioned iconPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_icon_pos')),
        );
        AnimatedPositioned labelPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_label_pos')),
        );
        AnimatedPositioned textPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_text_pos')),
        );

        expect(iconPositioned.left, equals(16.0));
        expect(labelPositioned.left, equals(48.0));
        expect(labelPositioned.top, equals(19.0));
        expect(textPositioned.left, equals(48.0));

        // 2. Focused state:
        // - Icon slides into left wall past 0.0 (left: -32.0)
        // - Label slides left to 16.0 and morphs up to top: 11.5
        // - TextField slides left to 16.0
        // - No opacity widgets are used on the icon (pure physical clipping motion)
        focusNode.requestFocus();
        controller.text = 'anas';
        await tester.pumpAndSettle();

        iconPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_icon_pos')),
        );
        labelPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_label_pos')),
        );
        textPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_text_pos')),
        );

        expect(iconPositioned.left, equals(-32.0));
        expect(labelPositioned.left, equals(16.0));
        expect(labelPositioned.top, equals(11.5));
        expect(textPositioned.left, equals(16.0));

        // Verify no Opacity or AnimatedOpacity widgets wrap the icon
        final Finder iconFinder = find.byIcon(Icons.person_outline_rounded);
        expect(find.ancestor(of: iconFinder, matching: find.byType(Opacity)), findsNothing);
        expect(find.ancestor(of: iconFinder, matching: find.byType(AnimatedOpacity)), findsNothing);

        final RenderBox containerBox = tester.renderObject(find.byType(AnimatedContainer).first);
        final RenderBox labelBox = tester.renderObject(find.text('Nama Lengkap'));
        final RenderBox fieldBox = tester.renderObject(find.byType(TextField));

        final Offset labelPos = labelBox.localToGlobal(Offset.zero, ancestor: containerBox);
        final Offset fieldPos = fieldBox.localToGlobal(Offset.zero, ancestor: containerBox);

        final double topSpace = labelPos.dy;
        final double gap = fieldPos.dy - (labelPos.dy + labelBox.size.height);
        final double bottomSpace = containerBox.size.height - (fieldPos.dy + fieldBox.size.height);

        // Verify top and bottom padding from container wrapper are symmetrical (within 0.5px)
        expect((topSpace - bottomSpace).abs(), lessThan(0.5));
        // Verify gap between label and value is narrow (around 2.0px)
        expect(gap, closeTo(2.0, 0.5));

        // 3. Unfocus and clear -> slides back to original positions
        controller.clear();
        focusNode.unfocus();
        await tester.pumpAndSettle();

        iconPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_icon_pos')),
        );
        labelPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_label_pos')),
        );
        textPositioned = tester.widget<AnimatedPositioned>(
          find.byKey(const ValueKey<String>('auth_input_field_text_pos')),
        );

        expect(iconPositioned.left, equals(16.0));
        expect(labelPositioned.left, equals(48.0));
        expect(labelPositioned.top, equals(19.0));
        expect(textPositioned.left, equals(48.0));
      },
    );

    testWidgets('AccountSwitchAction renders message and label with natural single-space spacing', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountSwitchAction(
              message: 'Sudah punya akun? ',
              actionLabel: 'Masuk',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sudah punya akun? Masuk', findRichText: true));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AuthInputField exposes accessible semantics label for screen readers', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final TextEditingController controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthInputField(
              label: 'Nama lengkap',
              hintText: 'Masukkan nama',
              leadingIcon: Icons.person_outline_rounded,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Nama lengkap'), findsOneWidget);
      handle.dispose();
    });
  });
}
