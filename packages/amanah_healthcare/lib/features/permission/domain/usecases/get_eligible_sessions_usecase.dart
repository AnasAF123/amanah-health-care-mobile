import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class GetEligibleSessionsUseCase {
  const GetEligibleSessionsUseCase(this._repository);

  final PermissionRepository _repository;

  Future<List<EligibleSession>> execute(String date) {
    return _repository.getEligibleSessions(date);
  }
}
