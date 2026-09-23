import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_notice_banner.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_duration_info_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AmanahNoticeBanner Widget Tests', () {
    testWidgets('renders warning banner with message and dismiss action', (
      WidgetTester tester,
    ) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahNoticeBanner(
              message: 'Batas shift telah tercapai.',
              variant: AmanahNoticeVariant.warning,
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Batas shift telah tercapai.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('renders info banner with custom message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahNoticeBanner(
              message: 'Waktu selesai dihitung otomatis.',
              variant: AmanahNoticeVariant.info,
            ),
          ),
        ),
      );

      expect(find.text('Waktu selesai dihitung otomatis.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });
  });

  group('AmanahScheduleDurationInfoDrawer Widget Tests', () {
    testWidgets('displays dynamic duration policy (30 menit) without hardcoding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AmanahScheduleDurationInfoDrawer.show(
                      context,
                      durationMinutes: 30,
                    );
                  },
                  child: const Text('Buka Info'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Buka Info'));
      await tester.pumpAndSettle();

      expect(find.text('Ketentuan Waktu Praktik'), findsOneWidget);
      expect(find.text('Durasi per Pasien'), findsOneWidget);
      expect(find.text('30 Menit'), findsOneWidget);
      expect(find.text('Jam Selesai ("To")'), findsOneWidget);
      expect(find.text('Dihitung Otomatis'), findsOneWidget);

      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      expect(find.text('Ketentuan Waktu Praktik'), findsNothing);
    });

    testWidgets('displays dynamic duration policy (20 menit) when customized by clinic', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    AmanahScheduleDurationInfoDrawer.show(
                      context,
                      durationMinutes: 20,
                    );
                  },
                  child: const Text('Buka Info 20'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Buka Info 20'));
      await tester.pumpAndSettle();

      expect(find.text('20 Menit'), findsOneWidget);
      expect(find.text('30 Menit'), findsNothing);
    });
  });

  group('AmanahAddEditScheduleDrawer Header Info Tooltip Integration', () {
    testWidgets('Header info button opens AmanahScheduleDurationInfoDrawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahAddEditScheduleDrawer(
              initialDate: DateTime(2026, 9, 24),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top-right header info button
      final Finder infoBtn = find.byTooltip('Informasi Ketentuan Praktik');
      expect(infoBtn, findsOneWidget);

      await tester.tap(infoBtn);
      await tester.pumpAndSettle();

      // Verify the duration info modal opened
      expect(find.text('Ketentuan Waktu Praktik'), findsOneWidget);
      expect(find.text('Durasi per Pasien'), findsOneWidget);
      expect(find.text('Mengerti'), findsOneWidget);
    });
  });

  group('AmanahAddEditScheduleDrawer Validation & Modal Drawer Tests', () {
    testWidgets(
      'displays modal drawer announcement and zero SnackBars when validation fails',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AmanahAddEditScheduleDrawer(
                initialDate: DateTime(2026, 9, 24),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // On add schedule, all sessions are unselected / blank by default.
        // Tap "Tambah Jadwal" button directly
        final Finder submitBtn = find.widgetWithText(AmanahButton, 'Tambah Jadwal');
        expect(submitBtn, findsOneWidget);
        await tester.tap(submitBtn);
        await tester.pumpAndSettle();

        // Validation announcement modal drawer MUST open
        expect(find.text('Validasi Jadwal Praktik'), findsOneWidget);
        expect(
          find.text('Aktifkan minimal satu sesi praktik untuk menyimpan jadwal.'),
          findsOneWidget,
        );

        // Verify NO SnackBar was used (which would render behind modal bottom sheet)
        expect(find.byType(SnackBar), findsNothing);

        // Tap "Mengerti" button to dismiss the validation modal
        await tester.tap(find.text('Mengerti'));
        await tester.pumpAndSettle();
        expect(
          find.text('Aktifkan minimal satu sesi praktik untuk menyimpan jadwal.'),
          findsNothing,
        );
      },
    );
  });
}
