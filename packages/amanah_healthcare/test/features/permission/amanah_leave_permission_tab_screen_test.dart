import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/amanah_home_shell.dart';
import 'package:amanah_healthcare/features/permission/data/amanah_permission_store.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_form_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/screen/amanah_leave_permission_tab_screen.dart';

const List<AmanahPermissionRecord> kTestPermissionRecords =
    <AmanahPermissionRecord>[
  AmanahPermissionRecord(
    id: 'perm_001',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-09-02',
    endDate: '2026-09-04',
    durationDays: 3,
    type: AmanahPermissionType.seminarSimposium,
    reason:
        'Menghadiri Kongres Nasional Ilmu Kesehatan Anak (KONIKA) XIX di Bali sebagai pembicara panelis.',
    substituteDoctor: 'dr. Budi Santoso, Sp.A',
    status: AmanahPermissionStatus.menunggu,
    createdAt: '2026-08-30T08:30:00Z',
  ),
  AmanahPermissionRecord(
    id: 'perm_002',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-09-15',
    endDate: '2026-09-16',
    durationDays: 2,
    type: AmanahPermissionType.urusanKeluarga,
    reason:
        'Keperluan mendesak keluarga di luar kota dan pendampingan wisuda keluarga inti.',
    substituteDoctor: 'dr. Ratna Sp.A',
    status: AmanahPermissionStatus.menunggu,
    createdAt: '2026-08-29T14:15:00Z',
  ),
  AmanahPermissionRecord(
    id: 'perm_003',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-08-10',
    endDate: '2026-08-12',
    durationDays: 3,
    type: AmanahPermissionType.cutiTahunan,
    reason:
        'Pengambilan cuti tahunan terjadwal Semester 2 (Hak cuti dokter spesialis).',
    substituteDoctor: 'dr. Budi Santoso, Sp.A',
    status: AmanahPermissionStatus.disetujui,
    createdAt: '2026-08-01T09:00:00Z',
    reviewedAt: '2026-08-02T11:20:00Z',
    reviewerName: 'dr. H. Hendra, Sp.JP (Direktur Pelayanan Medis)',
    reviewerNotes:
        'Disetujui. Kuota dokter pengganti rawat jalan dan jaga bangsal aman.',
  ),
  AmanahPermissionRecord(
    id: 'perm_004',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-07-20',
    endDate: '2026-07-21',
    durationDays: 2,
    type: AmanahPermissionType.tugasLuarRS,
    reason:
        'Bakti sosial pengobatan gratis dan edukasi stunting anak di Puskesmas Binaan.',
    substituteDoctor: 'dr. Kevin Pratama, Sp.A',
    status: AmanahPermissionStatus.disetujui,
    createdAt: '2026-07-10T10:00:00Z',
    reviewedAt: '2026-07-11T16:45:00Z',
    reviewerName: 'Bagian SDM & Komite Medik RS Amanah',
    reviewerNotes:
        'Surat tugas dinas luar telah diterbitkan nomor ST/2026/07/088.',
  ),
  AmanahPermissionRecord(
    id: 'perm_005',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-06-18',
    endDate: '2026-06-19',
    durationDays: 2,
    type: AmanahPermissionType.cutiTahunan,
    reason: 'Pengajuan cuti tambahan libur cuti bersama.',
    substituteDoctor: '-',
    status: AmanahPermissionStatus.ditolak,
    createdAt: '2026-06-12T07:45:00Z',
    reviewedAt: '2026-06-13T09:10:00Z',
    reviewerName: 'dr. H. Hendra, Sp.JP (Direktur Pelayanan Medis)',
    reviewerNotes:
        'Mohon maaf tidak dapat disetujui karena jadwal operasi dan visit pasien poliklinik sedang padat.',
  ),
  AmanahPermissionRecord(
    id: 'perm_006',
    userId: 'doc_001',
    userName: 'dr. Amelia Cantika',
    userRole: 'Dokter Spesialis Anak',
    userAvatarUrl: 'assets/amanah/auth/auth_background.png',
    startDate: '2026-05-05',
    endDate: '2026-05-06',
    durationDays: 2,
    type: AmanahPermissionType.izinSakit,
    reason: 'Demam dan radang tenggorokan akut, istirahat mandiri.',
    substituteDoctor: 'dr. Budi Santoso, Sp.A',
    status: AmanahPermissionStatus.dibatalkan,
    createdAt: '2026-05-04T19:00:00Z',
    cancelledAt: '2026-05-05T06:30:00Z',
  ),
];

void main() {
  setUp(() {
    AmanahPermissionStore.instance.seedForTesting(kTestPermissionRecords);
  });

  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Rayhan Pratama, Sp.A',
    email: 'rayhan@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  Widget createPermissionScreen({
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
      home: AmanahLeavePermissionTabScreen(onBack: onBack),
    );
  }

  group('Amanah Leave Permission Tab Screen Tests', () {
    testWidgets(
      'Renders header, filter chips with pending badge, and initial cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(createPermissionScreen());
        await tester.pumpAndSettle();

        // 1. Header
        expect(find.text('Perizinan'), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);

        // 2. Filter chips & Status Badges
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Menunggu'), findsWidgets);
        expect(find.text('Disetujui'), findsWidgets);
        expect(find.text('Ditolak'), findsWidgets);
        expect(find.text('Dibatalkan'), findsWidgets);

        // Initial pending count badge (2 items: perm_001 and perm_002)
        expect(find.text('2'), findsWidgets);

        // 3. Initial Visible Cards
        expect(find.text('Seminar / Simposium'), findsOneWidget);
        expect(find.text('Urusan Keluarga'), findsOneWidget);
        expect(find.text('Cuti Tahunan'), findsWidgets);
        expect(find.text('Tugas Luar RS'), findsOneWidget);

        // Scroll to reveal remaining items
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(find.text('Izin Sakit'), findsOneWidget);
      },
    );

    testWidgets('Filter by Menunggu displays only pending items', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap 'Menunggu' filter chip (first widget with 'Menunggu')
      await tester.tap(find.text('Menunggu').first);
      await tester.pumpAndSettle();

      expect(find.text('Seminar / Simposium'), findsOneWidget);
      expect(find.text('Urusan Keluarga'), findsOneWidget);
      expect(find.text('Tugas Luar RS'), findsNothing);
      expect(find.text('Izin Sakit'), findsNothing);
    });

    testWidgets('Tapping card opens Detail Drawer with full info', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap first card (Seminar / Simposium)
      await tester.tap(find.text('Seminar / Simposium').first);
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionDetailDrawer), findsOneWidget);
      expect(find.text('Detail perizinan'), findsOneWidget);
      expect(find.text('Durasi'), findsOneWidget);
      expect(find.text('3 Hari Kerja'), findsOneWidget);
      expect(find.text('Pesan / Alasan Perizinan'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AmanahPermissionDetailDrawer),
          matching: find.text(
            'Menghadiri Kongres Nasional Ilmu Kesehatan Anak (KONIKA) XIX di Bali sebagai pembicara panelis.',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Dokter Pengganti'), findsOneWidget);
      expect(find.text('dr. Budi Santoso, Sp.A'), findsOneWidget);
      expect(find.text('Edit Izin'), findsNothing);
      expect(find.text('Batalkan'), findsNothing);

      await tester.tap(find.byTooltip('Aksi perizinan'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Izin'), findsOneWidget);
      expect(find.text('Batalkan'), findsOneWidget);
    });

    testWidgets('Tapping Plus button opens Form Drawer to create permission', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Tap '+' button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionFormDrawer), findsOneWidget);
      expect(find.text('Pengajuan izin baru'), findsOneWidget);
      expect(find.text('Subjek Perizinan *'), findsOneWidget);
      expect(find.text('Rentang Tanggal *'), findsOneWidget);
      expect(find.text('Pesan / Alasan Perizinan *'), findsOneWidget);
      expect(find.text('Kirim Pengajuan Izin'), findsOneWidget);

      // Enter reason
      await tester.enterText(
        find.widgetWithText(TextField, 'Tuliskan keterangan keperluan izin...'),
        'Mengikuti pelatihan kegawatdaruratan anak di RS Rujukan.',
      );
      await tester.pumpAndSettle();

      // Tap Kirim Pengajuan Izin
      await tester.tap(find.text('Kirim Pengajuan Izin'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahPermissionFormDrawer), findsNothing);
    });

    testWidgets(
      'Bottom navigation bar navigates to Perizinan tab in HomeShell',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(() => tester.view.reset());

        await tester.pumpWidget(
          const MaterialApp(home: AmanahHomeShell(user: testUser)),
        );
        await tester.pumpAndSettle();

        // Bottom bar tab labeled 'Perizinan'
        expect(find.text('Perizinan'), findsOneWidget);

        // Tap 'Perizinan' in bottom navigation bar
        await tester.tap(find.text('Perizinan'));
        await tester.pumpAndSettle();

        expect(find.byType(AmanahLeavePermissionTabScreen), findsOneWidget);
        expect(find.text('Perizinan'), findsWidgets);
      },
    );

    testWidgets('Empty state displays when no permissions exist, and allows action', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      // Clear all records
      AmanahPermissionStore.instance.clear();

      await tester.pumpWidget(createPermissionScreen());
      await tester.pumpAndSettle();

      // Empty state should be visible
      expect(find.text('Belum Ada Pengajuan Izin'), findsOneWidget);
      expect(find.text('Ajukan Izin'), findsOneWidget);

      // Reseed store
      AmanahPermissionStore.instance.seedForTesting(kTestPermissionRecords);
      await tester.pumpAndSettle();

      // List should be restored
      expect(find.text('Seminar / Simposium'), findsOneWidget);
      expect(find.text('Belum Ada Pengajuan Izin'), findsNothing);
    });
  });
}
