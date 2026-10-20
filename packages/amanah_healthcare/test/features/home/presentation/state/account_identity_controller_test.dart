import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_credential_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_profile_store.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/home/presentation/state/account_identity_controller.dart';

class _FakeCredentialRepo extends StaffCredentialRepository {
  AmanahStaffProfile? updatedProfile;

  @override
  Future<AmanahStaffProfile> updateMyProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? birthPlace,
    String? birthDate,
    String? gender,
    String? nationalId,
    String? licenseNumber,
    Map<String, dynamic>? address,
  }) async {
    updatedProfile = AmanahStaffProfile(
      id: 'staff-1',
      userId: 'user-1',
      fullName: fullName ?? 'Dr. Test',
      profession: 'Dokter',
      birthPlace: birthPlace,
      birthDate: birthDate,
      gender: gender,
      staffCode: 'STF-DOK-001',
      nationalId: nationalId,
      addressModel: address != null ? AmanahStaffAddress.fromJson(address) : null,
    );
    return updatedProfile!;
  }

  @override
  Future<AmanahStaffProfile> getMyProfile() async {
    return updatedProfile ??
        const AmanahStaffProfile(
          id: 'staff-1',
          userId: 'user-1',
          fullName: 'Dr. Test',
          profession: 'Dokter',
        );
  }
}

void main() {
  group('AccountIdentityController Tests', () {
    const AmanahAuthUser testUser = AmanahAuthUser(
      id: 'user-1',
      fullName: 'Dr. Test',
      email: 'test@amanah.com',
      role: AmanahUserRole.doctor,
      phone: '08123456789',
      staff: AmanahStaffProfile(
        id: 'staff-1',
        userId: 'user-1',
        fullName: 'Dr. Test',
        profession: 'Dokter',
        poliklinikId: 'poli-1',
        poliklinikName: 'Poli Umum',
        birthPlace: 'Jakarta',
        birthDate: '1990-05-15',
        gender: 'male',
        staffCode: 'STF-DOK-001',
        nationalId: '3201234567890001',
        addressModel: AmanahStaffAddress(
          provinceCode: '31',
          provinceName: 'DKI Jakarta',
          regencyCode: '3171',
          regencyName: 'Kota Jakarta Selatan',
          districtCode: '3171010',
          districtName: 'Tebet',
          villageCode: '3171010001',
          villageName: 'Tebet Barat',
          line1: 'Jl. Tebet No. 10',
        ),
      ),
    );

    late StaffProfileStore store;
    late _FakeCredentialRepo fakeRepo;

    setUp(() {
      fakeRepo = _FakeCredentialRepo();
      store = StaffProfileStore.forTesting(repository: fakeRepo);
      store.seed(testUser.staff!);
    });

    test('initializes properties from user and store', () {
      final AccountIdentityController controller =
          AccountIdentityController(user: testUser, store: store);

      expect(controller.name, equals('Dr. Test'));
      expect(controller.phone, equals('08123456789'));
      expect(controller.email, equals('test@amanah.com'));
      expect(controller.birthPlace, equals('Jakarta'));
      expect(controller.birthDate, equals('1990-05-15'));
      expect(controller.gender, equals('male'));
      expect(controller.nik, equals('3201234567890001'));
      expect(controller.poliklinikName, equals('Poli Umum'));
      expect(controller.province?.id, equals('31'));
      expect(controller.regency?.id, equals('3171'));
      expect(controller.district?.id, equals('3171010'));
      expect(controller.village?.id, equals('3171010001'));
      expect(controller.line1, equals('Jl. Tebet No. 10'));

      controller.dispose();
    });

    test('updating province clears regency, district, and village', () async {
      final AccountIdentityController controller =
          AccountIdentityController(user: testUser, store: store);

      const RegionItem newProvince = RegionItem(
        id: '32',
        name: 'JAWA BARAT',
        label: 'Jawa Barat',
      );

      await controller.updateProvince(newProvince);

      expect(controller.province?.id, equals('32'));
      expect(controller.regency, isNull);
      expect(controller.district, isNull);
      expect(controller.village, isNull);

      controller.dispose();
    });

    test('updating regency clears district and village', () async {
      final AccountIdentityController controller =
          AccountIdentityController(user: testUser, store: store);

      const RegionItem newRegency = RegionItem(
        id: '3172',
        name: 'KOTA JAKARTA TIMUR',
        label: 'Kota Jakarta Timur',
      );

      await controller.updateRegency(newRegency);

      expect(controller.regency?.id, equals('3172'));
      expect(controller.district, isNull);
      expect(controller.village, isNull);

      controller.dispose();
    });

    test('formatBirthDateDisplay formats date cleanly', () {
      final AccountIdentityController controller =
          AccountIdentityController(user: testUser, store: store);

      final String formatted = controller.formatBirthDateDisplay();
      expect(formatted, isNotEmpty);
      expect(formatted, isNot(equals('Belum diisi')));

      controller.dispose();
    });
  });
}
