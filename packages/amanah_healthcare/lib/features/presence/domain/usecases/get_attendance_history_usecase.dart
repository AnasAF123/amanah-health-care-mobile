import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/repositories/attendance_repository.dart';

class GetAttendanceHistoryUseCase {
  const GetAttendanceHistoryUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<List<AttendanceRecord>> call() {
    return _repository.getMyHistory();
  }
}
