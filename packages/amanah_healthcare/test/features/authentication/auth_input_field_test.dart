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

    testWidgets('AuthInputField morphs IFTA label inside container frame when focused', (
      WidgetTester tester,
    ) async {
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

      // 1. Initial state: unfocused and empty -> label is optically centered vertically inside frame (top: 19.0)
      AnimatedPositioned labelPositioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(labelPositioned.top, equals(19.0));

      // 2. Focused state -> label morphs up with symmetrical wrapper padding and narrow 2px gap
      focusNode.requestFocus();
      controller.text = 'anas';
      await tester.pumpAndSettle();

      labelPositioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(labelPositioned.top, equals(11.5));

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
    });

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
