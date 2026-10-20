import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/region_api_service.dart';
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

class _FakeRegionApi extends RegionApiService {
  @override
  Future<List<RegionItem>> getProvinces({bool forceRefresh = false}) async => const <RegionItem>[
    RegionItem(id: '31', name: 'DKI JAKARTA'),
  ];

  @override
  Future<List<RegionItem>> getRegencies(String provinceId, {bool forceRefresh = false}) async =>
      const <RegionItem>[RegionItem(id: '3171', name: 'JAKARTA SELATAN')];

  @override
  Future<List<RegionItem>> getDistricts(String regencyId, {bool forceRefresh = false}) async =>
      const <RegionItem>[RegionItem(id: '3171010', name: 'TEBET')];

  @override
  Future<List<RegionItem>> getVillages(String districtId, {bool forceRefresh = false}) async =>
      const <RegionItem>[RegionItem(id: '3171010001', name: 'TEBET BARAT')];
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
    late _FakeRegionApi fakeRegionApi;

    setUp(() {
      fakeRepo = _FakeCredentialRepo();
      fakeRegionApi = _FakeRegionApi();
      store = StaffProfileStore.forTesting(repository: fakeRepo);
      store.seed(testUser.staff!);
    });

    test('initializes properties from user and store', () {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
      );

      expect(controller.name, equals('Dr. Test'));
      expect(controller.phone, equals('08123456789'));
      expect(controller.email, equals('test@amanah.com'));
      expect(controller.birthPlace, equals('Jakarta'));
      expect(controller.birthDate, equals('1990-05-15'));
      expect(controller.gender, equals('male'));
      expect(controller.nik, equals('3201234567890001'));
      expect(controller.poliklinikName, equals('Poli Umum'));
      expect(controller.poliklinikDisplay, equals('Poli Umum'));
      expect(controller.province?.id, equals('31'));
      expect(controller.regency?.id, equals('3171'));
      expect(controller.district?.id, equals('3171010'));
      expect(controller.village?.id, equals('3171010001'));
      expect(controller.line1, equals('Jl. Tebet No. 10'));
      expect(controller.hasProvince, isTrue);
      expect(controller.hasRegency, isTrue);
      expect(controller.hasDistrict, isTrue);
      expect(controller.birthDateParsed, equals(DateTime(1990, 5, 15)));

      controller.dispose();
    });

    test('updating province clears regency, district, and village', () async {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
      );

      const RegionItem newProvince = RegionItem(id: '32', name: 'JAWA BARAT', label: 'Jawa Barat');

      await controller.updateProvince(newProvince);

      expect(controller.province?.id, equals('32'));
      expect(controller.regency, isNull);
      expect(controller.district, isNull);
      expect(controller.village, isNull);
      expect(controller.hasProvince, isTrue);
      expect(controller.hasRegency, isFalse);
      expect(controller.hasDistrict, isFalse);

      controller.dispose();
    });

    test('updating regency clears district and village', () async {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
      );

      const RegionItem newRegency = RegionItem(
        id: '3172',
        name: 'KOTA JAKARTA TIMUR',
        label: 'Kota Jakarta Timur',
      );

      await controller.updateRegency(newRegency);

      expect(controller.regency?.id, equals('3172'));
      expect(controller.district, isNull);
      expect(controller.village, isNull);
      expect(controller.hasRegency, isTrue);
      expect(controller.hasDistrict, isFalse);

      controller.dispose();
    });

    test('formatBirthDateDisplay formats date cleanly', () {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
      );

      final String formatted = controller.formatBirthDateDisplay();
      expect(formatted, isNotEmpty);
      expect(formatted, isNot(equals('Belum diisi')));

      controller.dispose();
    });

    test('formatIsoDate formats date into yyyy-MM-dd pattern', () {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
      );

      expect(controller.formatIsoDate(DateTime(2026, 10, 20)), equals('2026-10-20'));

      controller.dispose();
    });

    test('region loader methods delegate to region service', () async {
      final AccountIdentityController controller = AccountIdentityController(
        user: testUser,
        store: store,
        regionApi: fakeRegionApi,
      );

      final List<RegionItem> provinces = await controller.loadProvinces();
      expect(provinces.length, equals(1));
      expect(provinces.first.id, equals('31'));

      final List<RegionItem> regencies = await controller.loadRegencies();
      expect(regencies.length, equals(1));
      expect(regencies.first.id, equals('3171'));

      final List<RegionItem> districts = await controller.loadDistricts();
      expect(districts.length, equals(1));
      expect(districts.first.id, equals('3171010'));

      final List<RegionItem> villages = await controller.loadVillages();
      expect(villages.length, equals(1));
      expect(villages.first.id, equals('3171010001'));

      controller.dispose();
    });
  });
}
