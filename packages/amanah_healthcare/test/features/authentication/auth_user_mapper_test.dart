import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/data/mappers/auth_user_mapper.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';

void main() {
  group('AuthUserMapper', () {
    test('maps doctor user json correctly', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'usr_doc_1',
        'name': 'dr. Zikri',
        'email': 'zikri@amanah.id',
        'phoneNumber': '08123456789',
        'role': 'doctor',
        'isEmailVerified': true,
        'needsOnboarding': false,
        'systemRole': 'DOCTOR',
        'staff': <String, dynamic>{
          'id': 'stf_1',
          'userId': 'usr_doc_1',
          'fullName': 'dr. Zikri Spesialis',
          'profession': 'DOKTER_UMUM',
          'idCardNumber': '3201234567890001',
          'isActive': true,
        },
      };

      final AmanahAuthUser user = AuthUserMapper.fromJson(json);

      expect(user.id, 'usr_doc_1');
      expect(user.fullName, 'dr. Zikri');
      expect(user.email, 'zikri@amanah.id');
      expect(user.role, AmanahUserRole.doctor);
      expect(user.isDoctor, isTrue);
      expect(user.isMidwife, isFalse);
      expect(user.isStaff, isFalse);
      expect(user.needsOnboarding, isFalse);
      expect(user.staff?.profession, 'DOKTER_UMUM');
    });

    test('maps midwife user json correctly', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'usr_mid_1',
        'fullName': 'Bidan Siti',
        'email': 'siti@amanah.id',
        'role': <String, dynamic>{'code': 'staff_midwife'},
        'needsOnboarding': false,
      };

      final AmanahAuthUser user = AuthUserMapper.fromJson(json);

      expect(user.id, 'usr_mid_1');
      expect(user.fullName, 'Bidan Siti');
      expect(user.role, AmanahUserRole.midwife);
      expect(user.isMidwife, isTrue);
    });

    test('defaults needsOnboarding to false when omitted by backend', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'usr_stf_1',
        'fullName': 'Staf Medis',
        'email': 'staff@amanah.id',
        'role': 'staff',
      };

      final AmanahAuthUser user = AuthUserMapper.fromJson(json);

      expect(user.needsOnboarding, isFalse);
    });

    test('respects needsOnboarding: true sent by backend for newly invited staff', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'usr_invited_1',
        'fullName': 'dr. Invited',
        'email': 'invited@amanah.id',
        'role': 'doctor',
        'needsOnboarding': true,
      };

      final AmanahAuthUser user = AuthUserMapper.fromJson(json);

      expect(user.needsOnboarding, isTrue);
    });

    test('creates custom initials avatar when image is null', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'usr_initials',
        'fullName': 'Ahmad Fauzi',
        'email': 'ahmad@amanah.id',
      };

      final AmanahAuthUser user = AuthUserMapper.fromJson(json);

      expect(user.avatar.initials, 'AF');
      expect(user.avatar.hasCustomAvatar, isFalse);
    });
  });
}
