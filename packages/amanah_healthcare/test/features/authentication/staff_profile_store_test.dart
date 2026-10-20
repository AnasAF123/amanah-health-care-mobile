import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_credential_repository.dart';
import 'package:amanah_healthcare/features/authentication/data/staff_profile_store.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

class _FakeStaffCredentialRepository extends StaffCredentialRepository {
  _FakeStaffCredentialRepository({required this.profileToReturn});

  final AmanahStaffProfile profileToReturn;
  int callCount = 0;

  @override
  Future<AmanahStaffProfile> getMyProfile() async {
    callCount++;
    return profileToReturn;
  }
}

void main() {
  group('StaffProfileStore SSOT Tests', () {
    const AmanahStaffProfile testProfile = AmanahStaffProfile(
      id: 'staff-123',
      userId: 'user-123',
      fullName: 'Dr. Zikri',
      profession: 'Dokter',
      birthPlace: 'Palembang',
      birthDate: '1995-01-10',
      gender: 'female',
      addressModel: AmanahStaffAddress(
        provinceCode: '16',
        provinceName: 'Sumatera Selatan',
        regencyCode: '1610',
        regencyName: 'Kabupaten Ogan Ilir',
        districtCode: '1610030',
        districtName: 'Rantau Alai',
        villageCode: '1610030013',
        villageName: 'Talang Sari',
        line1: 'Jalan Merdeka No 1',
      ),
    );

    test('seed updates store profile and notifies listeners', () {
      final StaffProfileStore store = StaffProfileStore.forTesting();
      int notified = 0;
      void listener() => notified++;
      store.addListener(listener);

      store.seed(testProfile);

      expect(store.profile, equals(testProfile));
      expect(store.status, equals(ProfileStatus.success));
      expect(notified, equals(1));

      store.removeListener(listener);
    });

    test('fetchProfile queries repository and updates store', () async {
      final StaffProfileStore store = StaffProfileStore.forTesting();
      final _FakeStaffCredentialRepository fakeRepo =
          _FakeStaffCredentialRepository(profileToReturn: testProfile);

      int notified = 0;
      void listener() => notified++;
      store.addListener(listener);

      await store.fetchProfile(repository: fakeRepo);

      expect(fakeRepo.callCount, equals(1));
      expect(store.profile, equals(testProfile));
      expect(store.status, equals(ProfileStatus.success));
      expect(notified, greaterThanOrEqualTo(1));

      store.removeListener(listener);
    });

    test('AmanahStaffAddress.fromJson normalizes hyphen and whitespace to null', () {
      final Map<String, dynamic> rawJson = <String, dynamic>{
        'province_code': ' - ',
        'province_name': 'Sumatera Selatan',
        'regency_code': '-',
        'regency_name': 'Kabupaten Ogan Ilir',
        'district_code': '',
        'district_name': 'Rantau Alai',
        'village_code': '  ',
        'village_name': 'Talang Sari',
        'line1': '-',
      };

      final AmanahStaffAddress address = AmanahStaffAddress.fromJson(rawJson);

      expect(address.provinceCode, isNull);
      expect(address.provinceName, 'Sumatera Selatan');
      expect(address.regencyCode, isNull);
      expect(address.regencyName, 'Kabupaten Ogan Ilir');
      expect(address.districtCode, isNull);
      expect(address.districtName, 'Rantau Alai');
      expect(address.villageCode, isNull);
      expect(address.villageName, 'Talang Sari');
      expect(address.line1, isNull);
    });
  });
}
