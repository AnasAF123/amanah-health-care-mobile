import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_notification_tab_screen.dart';

const List<AmanahNotificationItem> kTestNotifications = <AmanahNotificationItem>[
  AmanahNotificationItem(
    id: 'notif_1',
    title: 'Pasien Siap di Ruang Periksa',
    desc:
        'An. Kevin Sanjaya (No. Antrean A-04) telah selesai asesmen tanda vital oleh perawat.',
    time: 'Baru saja',
    timestamp: '07:45',
    category: AmanahNotificationCategory.queue,
    isUnread: true,
    isUrgent: false,
    visual: AmanahNotificationVisual.queueVitals,
  ),
  AmanahNotificationItem(
    id: 'notif_2',
    title: 'Hasil Kritis Laboratorium Darah',
    desc:
        'Hb 7.2 g/dL & Trombosit 45.000 pada pasien Ny. Ratna Dewi (Kamar 204B) perlu verifikasi DPJP.',
    time: '12 mnt lalu',
    timestamp: '07:33',
    category: AmanahNotificationCategory.clinical,
    isUnread: true,
    isUrgent: true,
    visual: AmanahNotificationVisual.clinicalCritical,
  ),
  AmanahNotificationItem(
    id: 'notif_3',
    title: 'Konsultasi Antar Spesialis',
    desc:
        'dr. Budi Santoso, Sp.A meminta lembar rujukan kasus bronkiolitis anak ruang PICU.',
    time: '45 mnt lalu',
    timestamp: '07:00',
    category: AmanahNotificationCategory.clinical,
    isUnread: true,
    isUrgent: false,
    visual: AmanahNotificationVisual.clinicalConsult,
  ),
  AmanahNotificationItem(
    id: 'notif_4',
    title: 'Konfirmasi Jadwal Shift Sore',
    desc:
        'Poli Spesialis Anak Sesi 2 dimulai pukul 14:00 - 18:00 WIB (Kuota 15 pasien terisi).',
    time: '2 jam lalu',
    timestamp: '05:45',
    category: AmanahNotificationCategory.shift,
    isUnread: false,
    isUrgent: false,
    visual: AmanahNotificationVisual.shiftSchedule,
  ),
  AmanahNotificationItem(
    id: 'notif_5',
    title: 'Laporan Hasil Radiologi Toraks',
    desc:
        'Hasil foto Rontgen Thorax AP/Lat pasien By. Alif Pratama sudah dapat diakses via SIMRS.',
    time: '3 jam lalu',
    timestamp: '04:30',
    category: AmanahNotificationCategory.clinical,
    isUnread: false,
    isUrgent: false,
    visual: AmanahNotificationVisual.clinicalReport,
  ),
  AmanahNotificationItem(
    id: 'notif_6',
    title: 'Pengingat Batas Verifikasi Resep',
    desc:
        'Terdapat 3 resep elektronik pasien rawat jalan yang menunggu paraf digital Anda.',
    time: 'Kemarin',
    timestamp: '25 Ags',
    category: AmanahNotificationCategory.shift,
    isUnread: false,
    isUrgent: false,
    visual: AmanahNotificationVisual.shiftReminder,
  ),
];

void main() {
  setUp(() {
    AmanahNotificationStore.instance.seedForTesting(kTestNotifications);
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
