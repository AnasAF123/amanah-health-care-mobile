import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/domain/amanah_notification_model.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_notification_tab_screen.dart';

void main() {
  setUp(() {
    AmanahNotificationStore.instance.reset();
  });

  Widget createNotificationScreen({
    VoidCallback? onBack,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: AmanahNotificationTabScreen(onBack: onBack),
    );
  }

  group('Amanah Notification Tab Screen Tests', () {
    testWidgets(
      'Renders header, filter chips, and 6 initial notification items',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createNotificationScreen());
        await tester.pumpAndSettle();

        // 1. Header
        expect(find.text('Notifikasi'), findsOneWidget);
        expect(find.text('3 belum dibaca'), findsOneWidget);
        expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

        // 2. Filter chips
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Antrean'), findsOneWidget);
        expect(find.text('Klinis & Lab'), findsOneWidget);
        expect(find.text('Shift & Poli'), findsOneWidget);

        // 3. Initial Items
        expect(find.text('Pasien Siap di Ruang Periksa'), findsOneWidget);
        expect(find.text('Hasil Kritis Laboratorium Darah'), findsOneWidget);
        expect(find.text('Konsultasi Antar Spesialis'), findsOneWidget);
        expect(find.text('Konfirmasi Jadwal Shift Sore'), findsOneWidget);
        expect(find.text('Laporan Hasil Radiologi Toraks'), findsOneWidget);
        expect(find.text('Pengingat Batas Verifikasi Resep'), findsOneWidget);
      },
    );

    testWidgets('Filtering by category displays only items of that category', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createNotificationScreen());
      await tester.pumpAndSettle();

      // Tap 'Antrean' chip
      await tester.tap(find.text('Antrean'));
      await tester.pumpAndSettle();

      expect(find.text('Pasien Siap di Ruang Periksa'), findsOneWidget);
      expect(find.text('Hasil Kritis Laboratorium Darah'), findsNothing);
      expect(find.text('Konfirmasi Jadwal Shift Sore'), findsNothing);

      // Tap 'Klinis & Lab' chip
      await tester.tap(find.text('Klinis & Lab'));
      await tester.pumpAndSettle();

      expect(find.text('Hasil Kritis Laboratorium Darah'), findsOneWidget);
      expect(find.text('Konsultasi Antar Spesialis'), findsOneWidget);
      expect(find.text('Laporan Hasil Radiologi Toraks'), findsOneWidget);
      expect(find.text('Pasien Siap di Ruang Periksa'), findsNothing);

      // Tap 'Shift & Poli' chip
      await tester.ensureVisible(find.text('Shift & Poli'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shift & Poli'));
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Jadwal Shift Sore'), findsOneWidget);
      expect(find.text('Pengingat Batas Verifikasi Resep'), findsOneWidget);
      expect(find.text('Pasien Siap di Ruang Periksa'), findsNothing);
    });

    testWidgets(
      'Tapping notification opens detail modal and marks it as read',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createNotificationScreen());
        await tester.pumpAndSettle();

        expect(find.text('3 belum dibaca'), findsOneWidget);

        // Tap on 'Pasien Siap di Ruang Periksa'
        await tester.tap(find.text('Pasien Siap di Ruang Periksa'));
        await tester.pumpAndSettle();

        // Bottom sheet is shown without a redundant close action.
        expect(find.text('Detail notifikasi'), findsOneWidget);
        expect(find.text('07:45 WIB'), findsOneWidget);
        expect(find.text('Tutup'), findsNothing);

        // Unread count decreased to 2
        expect(find.text('2 belum dibaca'), findsOneWidget);
      },
    );

    testWidgets('Options menu: Tandai Semua Dibaca marks all items as read', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createNotificationScreen());
      await tester.pumpAndSettle();

      expect(find.text('3 belum dibaca'), findsOneWidget);

      // Open options menu
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tandai Semua Dibaca'), findsOneWidget);
      expect(find.text('Bersihkan Terbaca'), findsOneWidget);

      await tester.tap(find.text('Tandai Semua Dibaca'));
      await tester.pumpAndSettle();

      // All read: no 'belum dibaca' subtitle
      expect(find.text('3 belum dibaca'), findsNothing);
      expect(find.text('0 belum dibaca'), findsNothing);
    });

    testWidgets(
      'Options menu: Bersihkan Terbaca removes read notifications and shows empty state',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createNotificationScreen());
        await tester.pumpAndSettle();

        // Mark all read first
        AmanahNotificationStore.instance.markAllAsRead();
        await tester.pumpAndSettle();

        // Open options menu and clear read
        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Bersihkan Terbaca'));
        await tester.pumpAndSettle();

        // Empty state
        expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
        expect(
          find.text(
            'Semua pembaruan operasional klinis dan jadwal praktik sudah diperiksa.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AmanahNotificationTabScreen route renders notification screen',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).push(AmanahNotificationTabScreen.route()),
                    child: const Text('Buka Notifikasi'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Buka Notifikasi'));
        await tester.pumpAndSettle();

        expect(find.text('Pasien Siap di Ruang Periksa'), findsOneWidget);
        expect(find.text('Hasil Kritis Laboratorium Darah'), findsOneWidget);
      },
    );
  });
}
