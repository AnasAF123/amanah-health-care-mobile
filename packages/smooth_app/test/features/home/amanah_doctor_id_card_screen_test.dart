import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_doctor_id_card_components.dart';
import 'package:smooth_app/features/home/presentation/screen/amanah_doctor_id_card_screen.dart';

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '081234567890',
    password: 'password123',
  );

  const AmanahDoctorProfile testProfile = AmanahDoctorProfile(
    name: 'dr. Andika Perkasa, Sp.A',
    role: 'Dokter Spesialis Anak',
    hospital: 'RS AMANAH SEHAT',
    sip: '503/442.1/SIP-D/2026',
    avatarAsset: 'assets/images/doctors/man-doctor-1.png',
    greeting: 'Selamat Pagi',
    unreadNotifications: 2,
  );

  Widget createIdCardScreen({Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A44FF),
          brightness: brightness,
        ),
      ),
      home: const AmanahDoctorIdCardScreen(
        user: testUser,
        profile: testProfile,
      ),
    );
  }

  group('Amanah Doctor ID Card Screen Tests', () {
    testWidgets(
        'Renders header, stage, doctor details, and bottom action buttons',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createIdCardScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Header
      expect(find.byType(AmanahDoctorIdCardHeader), findsOneWidget);
      expect(find.text('Kartu Identitas'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2_rounded), findsOneWidget);

      // 3D Stage and Card Content
      expect(find.byType(AmanahDoctorIdCardStage), findsOneWidget);
      expect(find.text('dr. Andika Perkasa, Sp.A'), findsOneWidget);
      expect(find.text('Dokter Spesialis Anak'), findsOneWidget);
      expect(find.text('503/442.1/SIP-D/2026'), findsOneWidget);
      expect(find.text('RS AMANAH SEHAT'), findsOneWidget);

      // Bottom Actions
      expect(find.text('Bagikan'), findsOneWidget);
      expect(find.text('Unduh PDF'), findsOneWidget);
    });

    testWidgets(
        'Tapping Info icon opens Panduan & Informasi ID Card 3D drawer',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createIdCardScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Info Button
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDoctorIdInfoDrawer), findsOneWidget);
      expect(find.text('Panduan & Informasi ID Card 3D'), findsOneWidget);
      expect(find.text('Fisika 3D & Gesture Interaktif'), findsOneWidget);
      expect(find.text('Barcode & Token Presensi'), findsOneWidget);
      expect(find.text('Mengerti'), findsOneWidget);

      // Close drawer
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDoctorIdInfoDrawer), findsNothing);
    });

    testWidgets('Tapping QR icon opens QR Presensi & Akses IGD dialog',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createIdCardScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap QR Button
      await tester.tap(find.byIcon(Icons.qr_code_2_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDoctorIdQrDialog), findsOneWidget);
      expect(find.text('QR Presensi & Akses IGD'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahDoctorIdQrDialog), findsNothing);
    });

    testWidgets('Tapping card triggers 3D flip spin without errors',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createIdCardScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on the card to trigger 3D spin
      await tester.tap(find.byType(AmanahDoctorIdCardStage));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(AmanahDoctorIdCardStage), findsOneWidget);
    });

    testWidgets('Dragging card down and sideways stretches lanyard and rebounds',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(createIdCardScreen());
      await tester.pump(const Duration(milliseconds: 100));

      // Drag down and to the right by (80, 160)
      await tester.drag(find.byType(AmanahDoctorIdCardStage), const Offset(80, 160));
      await tester.pump(const Duration(milliseconds: 200));

      // Release and let spring physics settle
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(AmanahDoctorIdCardStage), findsOneWidget);
    });
  });
}
