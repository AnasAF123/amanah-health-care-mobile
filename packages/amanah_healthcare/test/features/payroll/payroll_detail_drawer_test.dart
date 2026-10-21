import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_detail_drawer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(PayrollEntry entry) {
    return MaterialApp(
      home: Scaffold(body: PayrollDetailDrawer(entry: entry)),
    );
  }

  group('PayrollDetailDrawer Widget Tests', () {
    testWidgets(
      'renders real attendance check-in, check-out, early departure badge, and notes when present',
      (WidgetTester tester) async {
        const PayrollEntry entry = PayrollEntry(
          id: 'entry-att-1',
          entryType: 'base_scheduled',
          sourceType: 'attendance',
          quantityHours: 6.0,
          hourlyRate: 150000.0,
          amount: 900000.0,
          description: 'Upah hari ini - Pelayanan (6 jam x Rp 150.000)',
          checkInAt: '2026-10-20 08:00:00.000+07',
          checkOutAt: '2026-10-20 14:00:00.000+07',
          isEarlyDeparture: true,
          notes: 'Izin dinas luar / visit rujukan',
          createdAt: '2026-10-20T11:00:00.000Z',
        );

        await tester.pumpWidget(buildTestableWidget(entry));
        await tester.pumpAndSettle();

        // Scaffold title & info tooltip modal trigger
        expect(find.text('Rincian perhitungan upah'), findsOneWidget);
        expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

        // Tap info icon opens Keterangan Transaksi dialog modal
        await tester.tap(find.byIcon(Icons.info_outline_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Keterangan Transaksi'), findsOneWidget);
        expect(find.text('Upah hari ini - Pelayanan (6 jam x Rp 150.000)'), findsOneWidget);
        await tester.tap(find.text('Mengerti'));
        await tester.pumpAndSettle();
        expect(find.text('Keterangan Transaksi'), findsNothing);

        // Real attendance clocking rows (without parentheses)
        expect(find.text('Jam Masuk'), findsOneWidget);
        expect(find.text('Jam Pulang'), findsOneWidget);

        // Standard financial rows
        expect(find.text('Total Jam Kerja'), findsOneWidget);
        expect(find.text('Tarif per Jam'), findsOneWidget);

        // Single Total Upah Bersih row at the bottom (zero header redundancy)
        expect(find.text('Total Upah Bersih'), findsOneWidget);
        expect(find.text('+Rp 900.000'), findsOneWidget);

        // Early departure badge & notes with 'Catatan Pulang' title
        expect(find.text('Pulang Lebih Awal'), findsOneWidget);
        expect(find.text('Catatan Pulang'), findsOneWidget);
        expect(find.text('Izin dinas luar / visit rujukan'), findsOneWidget);
      },
    );

    testWidgets(
      'hides attendance section completely when no attendance data is present (honest minimalism)',
      (WidgetTester tester) async {
        const PayrollEntry entry = PayrollEntry(
          id: 'entry-leave-1',
          entryType: 'leave_deduction',
          sourceType: 'leave_request',
          quantityHours: 11.0,
          hourlyRate: 150000.0,
          amount: 1650000.0,
          description: 'Gaji di potong - Izin/cuti (21 Okt 2026)',
          checkInAt: null,
          checkOutAt: null,
          isEarlyDeparture: false,
          notes: null,
          createdAt: '2026-10-21T08:37:54.949Z',
        );

        await tester.pumpWidget(buildTestableWidget(entry));
        await tester.pumpAndSettle();

        // Scaffold title
        expect(find.text('Rincian perhitungan upah'), findsOneWidget);

        // Deduction financial rows
        expect(find.text('Durasi Izin/Cuti'), findsOneWidget);
        expect(find.text('Tarif per Jam'), findsOneWidget);

        // Single Total Potongan row at the bottom
        expect(find.text('Total Potongan'), findsOneWidget);
        expect(find.text('-Rp 1.650.000'), findsOneWidget);

        // Attendance rows must NOT be present
        expect(find.text('Jam Masuk'), findsNothing);
        expect(find.text('Jam Pulang'), findsNothing);
        expect(find.text('Pulang Lebih Awal'), findsNothing);
        expect(find.text('Catatan Pulang'), findsNothing);
      },
    );
  });
}
