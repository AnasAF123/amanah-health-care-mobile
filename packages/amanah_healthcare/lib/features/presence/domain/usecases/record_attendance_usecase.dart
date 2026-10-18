import 'package:amanah_healthcare/features/presence/domain/entities/attendance_check_in_result.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';

class RecordAttendanceUseCase {
  const RecordAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceCheckInResult> call({
    required String qrToken,
    String? shift,
    String? deviceInfo,
  }) {
    return _repository.recordScan(
      qrToken: qrToken,
      shift: shift,
      deviceInfo: deviceInfo,
    );
  }
}
