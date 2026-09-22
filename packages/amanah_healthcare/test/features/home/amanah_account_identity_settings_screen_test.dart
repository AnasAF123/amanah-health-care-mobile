import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_token_storage.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_account_identity_settings_screen.dart';

class FakeAuthTokenStorage extends AmanahAuthTokenStorage {
  FakeAuthTokenStorage([this._token = 'test-token']);
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> deleteToken() async => _token = null;

  @override
  Future<bool> hasToken() async => _token != null && _token!.isNotEmpty;
}

class FakeIdentityAuthRepository extends AmanahAuthRepository {
  FakeIdentityAuthRepository({
    List<StaffCredentialModel>? initialCredentials,
  })  : _credentials = initialCredentials != null
            ? List<StaffCredentialModel>.from(initialCredentials)
            : <StaffCredentialModel>[],
        super(tokenStorage: FakeAuthTokenStorage());

  final List<StaffCredentialModel> _credentials;
  String? lastUpdatedName;
  String? lastUpdatedPhone;
  bool deleteCalled = false;

  @override
  Future<List<StaffCredentialModel>> getMyCredentials() async {
    return List<StaffCredentialModel>.from(_credentials);
  }

  @override
  Future<StaffCredentialModel> addCredential({
    required CredentialType type,
    required String number,
    String? issuer,
    String? issuedAt,
    String? expiresAt,
  }) async {
    final StaffCredentialModel newCred = StaffCredentialModel(
      id: 'cred-new-${_credentials.length + 1}',
      staffProfileId: 'staff-001',
      credentialType: type,
      credentialNumber: number,
      issuer: issuer,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      status: 'unverified',
    );
    _credentials.add(newCred);
    return newCred;
  }

  @override
  Future<StaffCredentialModel> updateCredential({
    required String credentialId,
    String? number,
    String? issuer,
    String? expiresAt,
    String? status,
  }) async {
    final int index = _credentials.indexWhere((StaffCredentialModel c) => c.id == credentialId);
    if (index >= 0) {
      final StaffCredentialModel updated = _credentials[index].copyWith(
        credentialNumber: number,
        issuer: issuer,
        expiresAt: expiresAt,
        status: status,
      );
      _credentials[index] = updated;
      return updated;
    }
    throw const AmanahAuthException('Kredensial tidak ditemukan.');
  }

  @override
  Future<bool> deleteCredential(String credentialId) async {
    deleteCalled = true;
    _credentials.removeWhere((StaffCredentialModel c) => c.id == credentialId);
    return true;
  }

  @override
  Future<AmanahStaffProfile> updateMyProfile({
    String? fullName,
    String? phoneNumber,
  }) async {
    lastUpdatedName = fullName;
    lastUpdatedPhone = phoneNumber;
    return AmanahStaffProfile(
      id: 'staff-001',
      userId: 'doc-001',
      fullName: fullName ?? 'dr. Andika Perkasa',
      phoneNumber: phoneNumber ?? '+62 812-3456-7890',
    );
  }
}

void main() {
  const AmanahAuthUser testUser = AmanahAuthUser(
    id: 'doc-001',
    role: AmanahUserRole.doctor,
    fullName: 'dr. Andika Perkasa',
    email: 'dokter@amanah.health',
    phone: '+62 812-3456-7890',
    password: 'password123',
    staff: AmanahStaffProfile(
      id: 'staff-001',
      userId: 'doc-001',
      practitionerId: 'SIP. 503/442.1/SIP-D/2026',
      fullName: 'dr. Andika Perkasa',
      profession: 'Dokter Spesialis Anak',
      phoneNumber: '+62 812-3456-7890',
    ),
  );

  Widget createTestWidget({
    required AmanahAuthRepository repo,
    VoidCallback? onBack,
  }) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A44FF)),
      ),
      home: Scaffold(
        body: AmanahAccountIdentitySettingsScreen(
          user: testUser,
          repository: repo,
          onBack: onBack,
        ),
      ),
    );
  }

  group('AmanahAccountIdentitySettingsScreen Widget Tests', () {
    testWidgets('Renders header, personal info, and immutable email policy', (
      WidgetTester tester,
    ) async {
      final FakeIdentityAuthRepository repo = FakeIdentityAuthRepository();

      await tester.pumpWidget(createTestWidget(repo: repo));
      await tester.pumpAndSettle();

      // Screen Header
      expect(find.text('Akun & identitas dokter'), findsOneWidget);

      // Section 1: Informasi pribadi dan kontak
      expect(find.text('Informasi pribadi dan kontak'), findsOneWidget);
      expect(find.text('Nama lengkap'), findsOneWidget);
      expect(find.text('dr. Andika Perkasa'), findsOneWidget);
      expect(find.text('Spesialisasi medis'), findsOneWidget);
      expect(find.text('Dokter Spesialis Anak'), findsOneWidget);
      expect(find.text('Nomor telepon / WhatsApp'), findsOneWidget);
      expect(find.text('+62 812-3456-7890'), findsOneWidget);

      // Immutable Email Row
      expect(find.text('Email resmi'), findsOneWidget);
      expect(find.text('dokter@amanah.health'), findsOneWidget);
      expect(
        find.text('Email terdaftar secara permanen untuk keperluan legalitas klinis.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);

      // Fallback NPWP / NIB displayed
      expect(find.text('NPWP'), findsOneWidget);
      expect(find.text('Nomor NIB'), findsOneWidget);
    });

    testWidgets('Renders dynamic credentials list with verified status badge', (
      WidgetTester tester,
    ) async {
      final FakeIdentityAuthRepository repo = FakeIdentityAuthRepository(
        initialCredentials: <StaffCredentialModel>[
          const StaffCredentialModel(
            id: 'cred-1',
            staffProfileId: 'staff-001',
            credentialType: CredentialType.sip,
            credentialNumber: '503/4421/SIP-D/2026',
            issuer: 'Dinas Kesehatan DKI Jakarta',
            status: 'verified',
          ),
          const StaffCredentialModel(
            id: 'cred-2',
            staffProfileId: 'staff-001',
            credentialType: CredentialType.str,
            credentialNumber: 'STR-31.1.1.100.1.20',
            issuer: 'KKI',
            status: 'unverified',
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(repo: repo));
      await tester.pumpAndSettle();

      // Credential 1 (SIP)
      expect(find.text('SIP (Surat Izin Praktik)'), findsOneWidget);
      expect(find.text('503/4421/SIP-D/2026'), findsOneWidget);
      expect(find.text('Terverifikasi'), findsOneWidget);

      // Credential 2 (STR)
      expect(find.text('STR (Surat Tanda Registrasi)'), findsOneWidget);
      expect(find.text('STR-31.1.1.100.1.20'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi'), findsOneWidget);
    });

    testWidgets('Tapping + Tambah Kredensial Medis opens dialog and adds credential', (
      WidgetTester tester,
    ) async {
      final FakeIdentityAuthRepository repo = FakeIdentityAuthRepository();

      await tester.pumpWidget(createTestWidget(repo: repo));
      await tester.pumpAndSettle();

      // Tap + Tambah Kredensial Medis
      await tester.tap(find.text('+ Tambah Kredensial Medis (SIP / STR)'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Kredensial Medis'), findsOneWidget);
      expect(find.text('Nomor Kredensial *'), findsOneWidget);

      // Fill in credential details
      await tester.enterText(
        find.widgetWithText(TextField, 'Contoh: 503/4421/SIP-D/2026'),
        '446/999/SIP-BARU/2026',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Contoh: Dinas Kesehatan DKI Jakarta'),
        'Dinas Kesehatan Kota Bandung',
      );
      await tester.pumpAndSettle();

      // Tap Simpan Kredensial
      await tester.tap(find.text('Simpan Kredensial'));
      await tester.pumpAndSettle();

      // Verify added in UI
      expect(find.text('446/999/SIP-BARU/2026'), findsOneWidget);
      expect(find.text('Penerbit: Dinas Kesehatan Kota Bandung'), findsOneWidget);
    });

    testWidgets('Tapping edit icon opens edit dialog and updates credential', (
      WidgetTester tester,
    ) async {
      final FakeIdentityAuthRepository repo = FakeIdentityAuthRepository(
        initialCredentials: <StaffCredentialModel>[
          const StaffCredentialModel(
            id: 'cred-1',
            staffProfileId: 'staff-001',
            credentialType: CredentialType.sip,
            credentialNumber: '503/ORIGINAL/SIP',
            status: 'verified',
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('503/ORIGINAL/SIP'), findsOneWidget);

      // Tap edit button
      await tester.tap(find.byTooltip('Edit Kredensial'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Kredensial SIP'), findsOneWidget);

      // Enter new number
      await tester.enterText(
        find.widgetWithText(TextField, '503/ORIGINAL/SIP'),
        '503/UPDATED/SIP/2026',
      );
      await tester.pumpAndSettle();

      // Save
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(find.text('503/UPDATED/SIP/2026'), findsOneWidget);
      expect(find.text('503/ORIGINAL/SIP'), findsNothing);
    });

    testWidgets('Tapping delete icon opens confirmation dialog and deletes credential', (
      WidgetTester tester,
    ) async {
      final FakeIdentityAuthRepository repo = FakeIdentityAuthRepository(
        initialCredentials: <StaffCredentialModel>[
          const StaffCredentialModel(
            id: 'cred-1',
            staffProfileId: 'staff-001',
            credentialType: CredentialType.sip,
            credentialNumber: '503/DELETE-ME/SIP',
            status: 'verified',
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('503/DELETE-ME/SIP'), findsOneWidget);

      // Tap delete button
      await tester.tap(find.byTooltip('Hapus Kredensial'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus SIP (Surat Izin Praktik)?'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(repo.deleteCalled, isTrue);
      expect(find.text('503/DELETE-ME/SIP'), findsNothing);
    });
  });
}
