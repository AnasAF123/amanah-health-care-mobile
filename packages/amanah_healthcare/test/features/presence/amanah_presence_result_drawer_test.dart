import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_drawer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(
    PresenceStatusPayload payload, {
    AmanahPresenceResultDrawerStyle style =
        AmanahPresenceResultDrawerStyle.badgeStage,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AmanahPresenceResultDrawer(
          payload: payload,
          style: style,
          onClose: () {},
        ),
      ),
    );
  }

  group('AmanahPresenceResultDrawer', () {
    testWidgets('renders badgeStage style with 3D badge hero and typography without redundant badge pills', (WidgetTester tester) async {
      final payload = PresenceStatusPayload.fromSuccess(
        timeFormatted: '08:44 WIB',
        isCheckOut: false,
        validatedDurationHours: 8.0,
      );

      await tester.pumpWidget(buildTestableWidget(payload, style: AmanahPresenceResultDrawerStyle.badgeStage));
      await tester.pumpAndSettle();

      // Title & message must be present
      expect(find.text('Presensi Masuk Berhasil'), findsOneWidget);
      expect(find.text('Presensi masuk dinas Anda telah berhasil diverifikasi dan tersimpan.'), findsOneWidget);

      // Eyebrow tag is removed for clean minimal design
      expect(find.text('TERVERIFIKASI • 08:44 WIB'), findsNothing);

      // Redundant badge pill must NOT be rendered
      expect(find.text('BERHASIL MASUK'), findsNothing);

      // Duration must be rendered
      expect(find.text('8.0 Jam Durasi Dinas'), findsOneWidget);

      // Action buttons must be rendered in-flow
      expect(find.text('Lihat Riwayat Absensi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('renders ambientRipple style as Option 2', (WidgetTester tester) async {
      final payload = PresenceStatusPayload.fromSuccess(
        timeFormatted: '08:44 WIB',
        isCheckOut: false,
        validatedDurationHours: 8.0,
      );

      await tester.pumpWidget(buildTestableWidget(payload, style: AmanahPresenceResultDrawerStyle.ambientRipple));
      await tester.pumpAndSettle();

      expect(find.text('Presensi Masuk Berhasil'), findsOneWidget);
      expect(find.text('Presensi masuk dinas Anda telah berhasil diverifikasi dan tersimpan.'), findsOneWidget);
      expect(find.text('08:44 WIB'), findsOneWidget);
      expect(find.text('8.0 Jam'), findsOneWidget);
      expect(find.text('Lihat Riwayat Absensi'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('renders error state consistently in badgeStage style', (WidgetTester tester) async {
      final payload = PresenceStatusPayload.fromError('Anda sudah melakukan presensi masuk hari ini.');

      await tester.pumpWidget(buildTestableWidget(payload, style: AmanahPresenceResultDrawerStyle.badgeStage));
      await tester.pumpAndSettle();

      // Title & message
      expect(find.text('Sudah Presensi Masuk'), findsOneWidget);
      expect(find.textContaining('Anda sudah melakukan presensi masuk hari ini'), findsOneWidget);

      // Redundant badge pill must NOT be rendered
      expect(find.text('SUDAH TERDATA'), findsNothing);

      // Primary action button
      expect(find.text('Saya Mengerti'), findsOneWidget);
    });
  });
}
