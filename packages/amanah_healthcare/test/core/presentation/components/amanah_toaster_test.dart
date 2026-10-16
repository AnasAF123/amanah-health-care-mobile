import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_toaster.dart';

void main() {
  testWidgets('AmanahToaster.error displays message with sliding animation in overlay',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  AmanahToaster.error(
                    context,
                    message: 'Akun Google ini belum terdaftar atau belum diundang sebagai staf/dokter klinik.',
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      find.text('Akun Google ini belum terdaftar atau belum diundang sebagai staf/dokter klinik.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

    // Dismiss manually
    AmanahToaster.dismiss();
    await tester.pumpAndSettle();

    expect(
      find.text('Akun Google ini belum terdaftar atau belum diundang sebagai staf/dokter klinik.'),
      findsNothing,
    );
  });

  testWidgets('AmanahToaster.success displays success icon and message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  AmanahToaster.success(
                    context,
                    message: 'Kata sandi berhasil diperbarui.',
                  );
                },
                child: const Text('Show Success'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Kata sandi berhasil diperbarui.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);

    AmanahToaster.dismiss();
    await tester.pumpAndSettle();
  });
}
