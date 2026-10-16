import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/authentication/domain/failures/auth_failure.dart';

void main() {
  group('AuthFailure hierarchy', () {
    test('subclasses inherit from AmanahAuthException and AuthFailure', () {
      const InvalidCredentialsFailure failure = InvalidCredentialsFailure();
      expect(failure, isA<AmanahAuthException>());
      expect(failure, isA<AuthFailure>());
      expect(failure, isA<Exception>());
      expect(failure.code, 'INVALID_CREDENTIALS');
    });

    test('PatientRestrictedFailure inherits from AmanahAuthPatientRestrictedException', () {
      const PatientRestrictedFailure failure = PatientRestrictedFailure();
      expect(failure, isA<AmanahAuthPatientRestrictedException>());
      expect(failure, isA<AmanahAuthException>());
      expect(failure.code, 'PATIENT_RESTRICTED');
    });

    test('NotAuthorizedFailure preserves backend SSOT message', () {
      const String backendMsg = 'Email anda belum diundang oleh admin klinik';
      const NotAuthorizedFailure failure = NotAuthorizedFailure(backendMsg);
      expect(failure.message, backendMsg);
      expect(failure.code, 'NOT_AUTHORIZED');
      expect(failure.toString(), backendMsg);
    });

    test('AccountInactiveFailure preserves backend SSOT message', () {
      const String backendMsg = 'Akun dokter anda dinonaktifkan oleh faskes';
      const AccountInactiveFailure failure = AccountInactiveFailure(backendMsg);
      expect(failure.message, backendMsg);
      expect(failure.code, 'ACCOUNT_INACTIVE');
    });
  });
}
