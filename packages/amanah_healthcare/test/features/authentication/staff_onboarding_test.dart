import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/screen/staff_onboarding_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_edit_profile_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';

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

    testWidgets(
      'Step 1 requires role selection before advancing, then advances to Step 2 and 3',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: const _TestAuthRepository(
                polikliniks: <StaffOnboardingPoliOption>[
                  StaffOnboardingPoliOption(
                    id: 'clinic-eye',
                    code: 'poli_mata',
                    name: 'Poli Mata',
                  ),
                  StaffOnboardingPoliOption(
                    id: 'clinic-dental',
                    code: 'poli_gigi',
                    name: 'Poli Gigi',
                  ),
                ],
              ),
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        // Step 1: Verify Header
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);

        // Step 1: Verify Role cards
        expect(find.text('Dokter'), findsOneWidget);
        expect(find.text('Bidan'), findsOneWidget);
        expect(find.text('Staf / Pegawai'), findsOneWidget);

        // Validation: Tapping next without selecting a role must NOT advance
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();
        expect(find.text('Kredensial SIP & STR'), findsNothing);

        // Select Dokter
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();

        // Advance to Step 2
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();

        // Step 2: Header & License field for doctor
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);
        expect(find.bySemanticsLabel('Nomor SIP / STR Dokter'), findsOneWidget);
        expect(find.text('Poli Mata'), findsOneWidget);
        expect(find.text('Poli Gigi'), findsOneWidget);
        expect(find.text('Poli Umum'), findsNothing);
        expect(find.text('Poli KIA'), findsNothing);

        // Advance to Step 3
        await tester.tap(find.text('Sedikit Lagi'));
        await tester.pumpAndSettle();

        // Step 3: Header & Avatar options
        expect(find.text('Foto Profil Tenaga Medis'), findsOneWidget);
        expect(find.text('Selesai'), findsOneWidget);

        // Test Back Button from Step 3 -> Step 2
        await tester.tap(find.bySemanticsLabel('Kembali ke langkah sebelumnya'));
        await tester.pumpAndSettle();

        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // Test Back Button from Step 2 -> Step 1
        await tester.tap(find.bySemanticsLabel('Kembali ke langkah sebelumnya'));
        await tester.pumpAndSettle();

        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
      },
    );

    testWidgets(
      'Selecting Staf / Pegawai advances to Step 2 with operational staff notice (no SIP required)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        // Tap on 'Staf / Pegawai'
        await tester.tap(find.text('Staf / Pegawai'));
        await tester.pumpAndSettle();

        expect(find.text('Lanjut ke Langkah 2'), findsOneWidget);

        // Advance to Step 2
        await tester.tap(find.text('Lanjut ke Langkah 2'));
        await tester.pumpAndSettle();

        // Verify SIP/STR field is NOT present for worker
        expect(find.bySemanticsLabel('Nomor SIP / STR Dokter'), findsNothing);
        expect(find.bySemanticsLabel('Nomor SIP / STR Bidan'), findsNothing);
        expect(find.text('Akses Staf Operasional'), findsOneWidget);
      },
    );

    testWidgets(
      'Completing Step 3 triggers AmanahSuccessDrawer and onOnboardingComplete',
      (WidgetTester tester) async {
        AmanahAuthUser? completedUser;
        final _RecordingAuthRepository repository = _RecordingAuthRepository();

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: repository,
              onOnboardingComplete: (AmanahAuthUser user) =>
                  completedUser = user,
              onLogout: () {},
            ),
          ),
        );

        // Select Doctor
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();

        // Advance Step 1 -> Step 2
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();

        // Advance Step 2 -> Step 3
        await tester.tap(find.text('Sedikit Lagi'));
        await tester.pumpAndSettle();

        // Tap 'Selesai'
        await tester.tap(find.text('Selesai'));
        await tester.pumpAndSettle();

        // Verify AmanahSuccessDrawer is shown!
        expect(find.byType(AmanahSuccessDrawer), findsOneWidget);
        expect(find.text('Selamat Bergabung!'), findsOneWidget);
        expect(find.text('Mulai Bertugas'), findsOneWidget);
        expect(find.textContaining('SIMRS'), findsNothing);
        expect(find.text('Status Kredensial'), findsNothing);

        // Tap 'Mulai Bertugas'
        await tester.tap(find.text('Mulai Bertugas'));
        await tester.pumpAndSettle();

        expect(completedUser, isNotNull);
        expect(completedUser!.needsOnboarding, isFalse);
        expect(repository.lastPoliklinikId, 'clinic-umum');
      },
    );

    testWidgets(
      'Tapping logout icon in AmanahScreenHeader triggers onLogout',
      (WidgetTester tester) async {
        bool loggedOut = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () => loggedOut = true,
            ),
          ),
        );

        expect(find.bySemanticsLabel('Keluar'), findsWidgets);
        await tester.tap(find.bySemanticsLabel('Keluar').first);
        await tester.pumpAndSettle();

        expect(loggedOut, isTrue);
      },
    );

    testWidgets(
      'Tapping footer "Sebelumnya" button navigates back step by step',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        // Step 1: No Sebelumnya button
        expect(find.text('Sebelumnya'), findsNothing);

        // Select role
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();

        // Advance to Step 2
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();

        // Step 2: Sebelumnya button is visible!
        expect(find.text('Sebelumnya'), findsOneWidget);

        // Advance to Step 3
        await tester.tap(find.text('Sedikit Lagi'));
        await tester.pumpAndSettle();

        // Step 3: Sebelumnya button is visible!
        expect(find.text('Sebelumnya'), findsOneWidget);

        // Tap Sebelumnya: goes to Step 2
        await tester.tap(find.text('Sebelumnya'));
        await tester.pumpAndSettle();
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // Tap Sebelumnya: goes to Step 1
        await tester.tap(find.text('Sebelumnya'));
        await tester.pumpAndSettle();
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
        expect(find.text('Sebelumnya'), findsNothing);
      },
    );

    testWidgets(
      'Android mobile system back navigation triggers previous step via PopScope',
      (WidgetTester tester) async {
        bool loggedOut = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () => loggedOut = true,
            ),
          ),
        );

        // Select role and advance to Step 2
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lanjut ke Data Izin'));
        await tester.pumpAndSettle();
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // Advance to Step 3
        await tester.tap(find.text('Sedikit Lagi'));
        await tester.pumpAndSettle();
        expect(find.text('Foto Profil Tenaga Medis'), findsOneWidget);

        // Simulate mobile back button via didPopRoute -> goes to Step 2
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // Simulate mobile back button -> goes to Step 1
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);

        // Simulate mobile back button on Step 1 -> triggers onLogout
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
        expect(loggedOut, isTrue);
      },
    );

    testWidgets(
      'Sebelumnya button uses AmanahButtonVariant.ghost (text-based style, no wrapper)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              initialStep: 1,
              initialRole: StaffOnboardingRoleOption.doctor,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        // Verify Step 2 is shown
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);

        // Find the "Sebelumnya" button and verify its variant is ghost
        final Finder sebelumnyaFinder = find.widgetWithText(
          AmanahButton,
          'Sebelumnya',
        );
        expect(sebelumnyaFinder, findsOneWidget);

        final AmanahButton button = tester.widget<AmanahButton>(
          sebelumnyaFinder,
        );
        expect(button.variant, AmanahButtonVariant.ghost);
        expect(button.isFullWidth, isTrue);
      },
    );

    testWidgets(
      'When onBack callback is provided, pressing back on Step 0 invokes onBack without logging out',
      (WidgetTester tester) async {
        bool backedOut = false;
        bool loggedOut = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              onOnboardingComplete: (_) {},
              onLogout: () => loggedOut = true,
              onBack: () => backedOut = true,
            ),
          ),
        );

        // Step 0: Header back button
        expect(find.bySemanticsLabel('Kembali'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Kembali'));
        await tester.pumpAndSettle();

        expect(backedOut, isTrue);
        expect(loggedOut, isFalse);

        // Reset and test mobile back button via didPopRoute
        backedOut = false;
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();

        expect(backedOut, isTrue);
        expect(loggedOut, isFalse);
      },
    );

    testWidgets(
      'Initializes with initialRole and initialLicenseNumber, emitting onProgressChanged',
      (WidgetTester tester) async {
        int? lastStep;
        StaffOnboardingRoleOption? lastRole;
        String? lastLicense;

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              initialStep: 1,
              initialRole: StaffOnboardingRoleOption.doctor,
              initialLicenseNumber: 'SIP.123/TEST/2026',
              repository: const _TestAuthRepository(),
              onProgressChanged: (int step, StaffOnboardingRoleOption? role, String license) {
                lastStep = step;
                lastRole = role;
                lastLicense = license;
              },
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        // Step 2 is active with preserved license text
        expect(find.text('Kredensial SIP & STR'), findsOneWidget);
        expect(find.text('SIP.123/TEST/2026'), findsOneWidget);

        // Tap Sebelumnya to go to Step 1
        await tester.tap(find.text('Sebelumnya'));
        await tester.pumpAndSettle();

        expect(find.text('Pilih Peran Staf Klinik'), findsOneWidget);
        expect(lastStep, 0);
        expect(lastRole, StaffOnboardingRoleOption.doctor);
        expect(lastLicense, 'SIP.123/TEST/2026');
      },
    );

    testWidgets(
      'Tapping Pilih Foto Profil in Step 3 opens AmanahAvatarPhotoSheet with camera, gallery, and file explorer options',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              initialStep: 2,
              initialRole: StaffOnboardingRoleOption.doctor,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (_) {},
              onLogout: () {},
            ),
          ),
        );

        expect(find.text('Foto Profil Tenaga Medis'), findsOneWidget);

        // Tap "Pilih Foto Profil" button
        expect(find.text('Pilih Foto Profil'), findsOneWidget);
        await tester.tap(find.text('Pilih Foto Profil'));
        await tester.pumpAndSettle();

        // Verify sheet is open with title and all 3 file source options
        expect(find.byType(AmanahAvatarPhotoSheet), findsOneWidget);
        expect(find.text('Foto Profil Tenaga Medis'), findsWidgets);
        expect(find.text('Ambil Foto dari Kamera'), findsOneWidget);
        expect(find.text('Pilih dari Galeri Perangkat'), findsOneWidget);
        expect(find.text('Pilih dari File Explorer / Disk HP'), findsOneWidget);
        expect(
          find.text('Jelajahi folder Unduhan (Downloads), Dokumen, atau Disk'),
          findsOneWidget,
        );
        expect(find.text('Atau Pilih Preset Avatar Klinis'), findsOneWidget);
      },
    );

    testWidgets(
      'Selecting preset avatar in Step 3 immediately completes onboarding and shows AmanahSuccessDrawer without intermediate page',
      (WidgetTester tester) async {
        AmanahAuthUser? completedUser;

        await tester.pumpWidget(
          MaterialApp(
            home: StaffOnboardingScreen(
              user: testUser,
              initialStep: 2,
              initialRole: StaffOnboardingRoleOption.doctor,
              repository: const _TestAuthRepository(),
              onOnboardingComplete: (AmanahAuthUser user) =>
                  completedUser = user,
              onLogout: () {},
            ),
          ),
        );

        // Tap "Pilih Foto Profil" to open sheet
        await tester.tap(find.text('Pilih Foto Profil'));
        await tester.pumpAndSettle();

        // Tap first preset avatar in the sheet
        final Finder presetImages = find.descendant(
          of: find.byType(AmanahAvatarPhotoSheet),
          matching: find.byType(Image),
        );
        expect(presetImages, findsWidgets);
        await tester.tap(presetImages.first);
        await tester.pumpAndSettle();

        // AmanahSuccessDrawer is shown immediately!
        expect(find.byType(AmanahSuccessDrawer), findsOneWidget);
        expect(find.text('Selamat Bergabung!'), findsOneWidget);
        expect(find.text('Mulai Bertugas'), findsOneWidget);

        // Tap "Mulai Bertugas"
        await tester.tap(find.text('Mulai Bertugas'));
        await tester.pumpAndSettle();

        expect(completedUser, isNotNull);
        expect(completedUser!.avatar.hasCustomAvatar, isTrue);
      },
    );
  });
}

class _TestAuthRepository extends AmanahAuthRepository {
  const _TestAuthRepository({
    this.polikliniks = const <StaffOnboardingPoliOption>[
      StaffOnboardingPoliOption(
        id: 'clinic-umum',
        code: 'poli_umum',
        name: 'Poli Umum',
      ),
      StaffOnboardingPoliOption(
        id: 'clinic-kia',
        code: 'poli_kia',
        name: 'Poli KIA',
      ),
    ],
  });

  final List<StaffOnboardingPoliOption> polikliniks;

  @override
  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks() async {
    return polikliniks;
  }

  @override
  Future<AmanahAuthUser?> completeStaffOnboarding({
    required String role,
    required String fullName,
    String? phoneNumber,
    String? profession,
    String? licenseNumber,
    String? staffCode,
    String? poliklinikId,
  }) async {
    return const AmanahAuthUser(
      id: 'test-user',
      role: AmanahUserRole.doctor,
      fullName: 'Zikri Ahmad',
      email: 'zikriahmadamikom@gmail.com',
      phone: '081234567890',
      needsOnboarding: false,
    );
  }
}

class _RecordingAuthRepository extends AmanahAuthRepository {
  String? lastPoliklinikId;

  @override
  Future<List<StaffOnboardingPoliOption>> fetchStaffOnboardingPolikliniks() async {
    return const <StaffOnboardingPoliOption>[
      StaffOnboardingPoliOption(
        id: 'clinic-umum',
        code: 'poli_umum',
        name: 'Poli Umum',
      ),
      StaffOnboardingPoliOption(
        id: 'clinic-kia',
        code: 'poli_kia',
        name: 'Poli KIA',
      ),
    ];
  }

  @override
  Future<AmanahAuthUser?> completeStaffOnboarding({
    required String role,
    required String fullName,
    String? phoneNumber,
    String? profession,
    String? licenseNumber,
    String? staffCode,
    String? poliklinikId,
  }) async {
    lastPoliklinikId = poliklinikId;
    return const AmanahAuthUser(
      id: 'test-user',
      role: AmanahUserRole.doctor,
      fullName: 'Zikri Ahmad',
      email: 'zikriahmadamikom@gmail.com',
      phone: '081234567890',
      needsOnboarding: false,
    );
  }
}
