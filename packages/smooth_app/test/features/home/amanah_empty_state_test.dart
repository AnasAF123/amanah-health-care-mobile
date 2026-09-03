import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_empty_state.dart';

void main() {
  group('AmanahEmptyState Master Component Tests', () {
    testWidgets('Renders viewport variant with title, message, and dual actions', (
      WidgetTester tester,
    ) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahEmptyState.viewport(
              icon: Icons.tune_rounded,
              title: 'Tidak ada data presensi',
              message:
                  'Tidak ditemukan riwayat presensi yang sesuai dengan filter yang diterapkan.',
              actionText: 'Ubah Filter',
              actionLeadingIcon: Icons.tune_rounded,
              onAction: () => primaryTapped = true,
              secondaryActionText: 'Reset Filter',
              secondaryActionLeadingIcon: Icons.restart_alt_rounded,
              onSecondaryAction: () => secondaryTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Tidak ada data presensi'), findsOneWidget);
      expect(
        find.text(
          'Tidak ditemukan riwayat presensi yang sesuai dengan filter yang diterapkan.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.tune_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);
      expect(find.text('Ubah Filter'), findsOneWidget);
      expect(find.text('Reset Filter'), findsOneWidget);

      await tester.tap(find.text('Ubah Filter'));
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('Reset Filter'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('Renders card variant with stacked full-width actions', (
      WidgetTester tester,
    ) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahEmptyState.card(
              icon: Icons.people_outline_rounded,
              title: 'Belum Ada Pasien Booking',
              message:
                  'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
              actionText: 'Tambah Jadwal',
              onAction: () => actionTapped = true,
              secondaryActionText: 'Lihat Sesi Dokter',
              onSecondaryAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Pasien Booking'), findsOneWidget);
      expect(
        find.text(
          'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tambah Jadwal'), findsOneWidget);
      expect(find.text('Lihat Sesi Dokter'), findsOneWidget);

      await tester.tap(find.text('Tambah Jadwal'));
      expect(actionTapped, isTrue);
    });

    testWidgets('Renders custom icon widget and brand tone correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahEmptyState.viewport(
              customIcon: Text(
                '#',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              tone: AmanahEmptyStateTone.brand,
              title: 'Belum ada antrean diproses',
              message:
                  'Tarik kartu antrean pasien ke bawah pada rel 3D untuk memproses dan memanggil pasien!',
            ),
          ),
        ),
      );

      expect(find.text('#'), findsOneWidget);
      expect(find.text('Belum ada antrean diproses'), findsOneWidget);
      expect(
        find.text(
          'Tarik kartu antrean pasien ke bawah pada rel 3D untuk memproses dan memanggil pasien!',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders compact variant gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahEmptyState.compact(
              icon: Icons.assignment_outlined,
              title: 'Belum ada laporan kendala',
              message: 'Belum ada riwayat laporan kendala teknis.',
              actionText: 'Laporkan kendala',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Belum ada laporan kendala'), findsOneWidget);
      expect(
        find.text('Belum ada riwayat laporan kendala teknis.'),
        findsOneWidget,
      );
      expect(find.text('Laporkan kendala'), findsOneWidget);
    });

    testWidgets('Renders 3D Isometric Empty Box from emptystate.html POC', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahEmptyState.box(
              title: 'Belum Ada Pasien Booking',
              message:
                  'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
              showAnimationControls: true,
              actionText: 'Tambah Jadwal',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Pasien Booking'), findsOneWidget);
      expect(
        find.text(
          'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
        ),
        findsOneWidget,
      );
      expect(find.text('Tambah Jadwal'), findsOneWidget);
      expect(find.text('Ulangi Animasi'), findsOneWidget);
      expect(find.text('Jeda Animasi'), findsOneWidget);

      // Verify custom painter is rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
