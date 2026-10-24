import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';

class CheckoutAttendanceUseCase {
  const CheckoutAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceCheckInResult> call({
    String? qrToken,
    AttendanceMethod? method,
    String? checkoutTicket,
    String? notes,
  }) {
    return _repository.recordCheckout(
      qrToken: qrToken,
      method: method,
      checkoutTicket: checkoutTicket,
      notes: notes,
    );
  }
}
