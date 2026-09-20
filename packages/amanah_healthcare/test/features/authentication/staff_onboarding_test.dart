import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/staff_onboarding_screen.dart';

void main() {
  group('Amanah Staff Role & Onboarding Domain Tests', () {
    test('Correctly parses all staff roles from backend contract', () {
      expect(AmanahAuthUser.parseRole('doctor'), AmanahUserRole.doctor);
      expect(AmanahAuthUser.parseRole('staff_doctor'), AmanahUserRole.doctor);
      expect(AmanahAuthUser.parseRole('staffDoctor'), AmanahUserRole.doctor);

      expect(AmanahAuthUser.parseRole('midwife'), AmanahUserRole.midwife);
      expect(AmanahAuthUser.parseRole('staff_midwife'), AmanahUserRole.midwife);
      expect(AmanahAuthUser.parseRole('staffMidwife'), AmanahUserRole.midwife);

      expect(AmanahAuthUser.parseRole('worker'), AmanahUserRole.staff);
      expect(AmanahAuthUser.parseRole('staff_worker'), AmanahUserRole.staff);
      expect(AmanahAuthUser.parseRole('staffWorker'), AmanahUserRole.staff);
      expect(AmanahAuthUser.parseRole('staff'), AmanahUserRole.staff);
    });

    test('Parses fromBetterAuthJson with needsOnboarding flag and staff profile', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'user-123',
        'name': 'dr. Zikri Ahmad, Sp.A',
        'email': 'zikriahmadamikom@gmail.com',
        'phoneNumber': '+6281234567890',
        'systemRole': 'STAF',
        'needsOnboarding': true,
        'role': <String, dynamic>{
          'code': 'staff_doctor',
          'name': 'STAF',
        },
        'staff': <String, dynamic>{
          'id': 'stf-001',
          'userId': 'user-123',
          'fullName': 'dr. Zikri Ahmad, Sp.A',
          'profession': 'Dokter Spesialis Anak',
        },
      };

      final AmanahAuthUser user = AmanahAuthUser.fromBetterAuthJson(json);
      expect(user.id, 'user-123');
      expect(user.role, AmanahUserRole.doctor);
      expect(user.isDoctor, isTrue);
      expect(user.needsOnboarding, isTrue);
      expect(user.staff?.fullName, 'dr. Zikri Ahmad, Sp.A');
      expect(user.staff?.profession, 'Dokter Spesialis Anak');
    });
  });

  group('StaffOnboardingScreen Widget Tests', () {
    const AmanahAuthUser testUser = AmanahAuthUser(
      id: 'test-user',
      role: AmanahUserRole.staff,
      fullName: 'Zikri Ahmad',
      email: 'zikriahmadamikom@gmail.com',
      phone: '081234567890',
      needsOnboarding: true,
    );

    testWidgets('Renders all 3 role options and license field for doctor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StaffOnboardingScreen(
            user: testUser,
            onOnboardingComplete: (_) {},
            onLogout: () {},
          ),
        ),
      );

      // Verify Role cards
      expect(find.text('Dokter'), findsOneWidget);
      expect(find.text('Bidan'), findsOneWidget);
      expect(find.text('Staf / Pegawai'), findsOneWidget);

      // Verify SIP / STR field is present initially (doctor selected by default)
      expect(find.bySemanticsLabel('Nomor SIP / STR Dokter'), findsOneWidget);
    });

    testWidgets('Switching role to Staf / Pegawai removes SIP / STR field requirement', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StaffOnboardingScreen(
            user: testUser,
            onOnboardingComplete: (_) {},
            onLogout: () {},
          ),
        ),
      );

      // Initially doctor is selected
      expect(find.bySemanticsLabel('Nomor SIP / STR Dokter'), findsOneWidget);

      // Tap on 'Staf / Pegawai'
      await tester.tap(find.text('Staf / Pegawai'));
      await tester.pumpAndSettle();

      // Verify SIP/STR field is gone for general worker/staff
      expect(find.bySemanticsLabel('Nomor SIP / STR Dokter'), findsNothing);
      expect(find.bySemanticsLabel('Nomor SIP / STR Bidan'), findsNothing);
    });
  });
}
