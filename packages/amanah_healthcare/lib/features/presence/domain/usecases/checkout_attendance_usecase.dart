import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';

class CheckoutAttendanceUseCase {
  const CheckoutAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceCheckInResult> call({String? qrToken}) {
    return _repository.recordCheckout(qrToken: qrToken);
  }
}
