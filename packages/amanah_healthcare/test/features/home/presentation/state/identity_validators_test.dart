import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/account_identity/identity_validators.dart';

void main() {
  group('IdentityValidators Tests', () {
    group('NIK validation', () {
      test('valid 16 digit number returns null', () {
        expect(IdentityValidators.nik('3201234567890001'), isNull);
      });

      test('empty string returns error', () {
        expect(IdentityValidators.nik(''), equals('NIK tidak boleh kosong.'));
        expect(IdentityValidators.nik('   '), equals('NIK tidak boleh kosong.'));
      });

      test('fewer than 16 digits returns error', () {
        expect(
          IdentityValidators.nik('123456789012345'),
          equals('NIK harus terdiri dari 16 digit angka.'),
        );
      });

      test('more than 16 digits returns error', () {
        expect(
          IdentityValidators.nik('12345678901234567'),
          equals('NIK harus terdiri dari 16 digit angka.'),
        );
      });

      test('non-digit characters return error', () {
        expect(
          IdentityValidators.nik('320123456789000a'),
          equals('NIK harus terdiri dari 16 digit angka.'),
        );
        expect(
          IdentityValidators.nik('STF-DOK-57630000'),
          equals('NIK harus terdiri dari 16 digit angka.'),
        );
      });
    });

    group('Phone validation', () {
      test('valid phone number returns null', () {
        expect(IdentityValidators.phone('08123456789'), isNull);
        expect(IdentityValidators.phone('081234567'), isNull);
      });

      test('empty string returns error', () {
        expect(
          IdentityValidators.phone(''),
          equals('Nomor telepon tidak boleh kosong.'),
        );
      });

      test('less than 9 digits returns error', () {
        expect(
          IdentityValidators.phone('08123456'),
          equals('Nomor telepon minimal 9 digit.'),
        );
      });
    });

    group('Email validation', () {
      test('valid email returns null', () {
        expect(IdentityValidators.email('doctor@amanah.com'), isNull);
        expect(IdentityValidators.email('staff.medis@rs-amanah.co.id'), isNull);
      });

      test('empty string returns error', () {
        expect(
          IdentityValidators.email(''),
          equals('Email tidak boleh kosong.'),
        );
      });

      test('missing @ or domain returns error', () {
        expect(
          IdentityValidators.email('invalid-email'),
          equals('Format email tidak valid.'),
        );
        expect(
          IdentityValidators.email('user@'),
          equals('Format email tidak valid.'),
        );
        expect(
          IdentityValidators.email('@domain.com'),
          equals('Format email tidak valid.'),
        );
        expect(
          IdentityValidators.email('user@..'),
          equals('Format email tidak valid.'),
        );
      });
    });
  });
}
