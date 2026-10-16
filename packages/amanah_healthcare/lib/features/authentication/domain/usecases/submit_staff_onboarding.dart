import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/data/dto/staff_onboarding_dto.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';

class SubmitStaffOnboardingUseCase
    implements UseCase<AmanahAuthUser?, StaffOnboardingDto> {
  const SubmitStaffOnboardingUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AmanahAuthUser?> call(StaffOnboardingDto params) {
    return _repository.submitStaffOnboarding(params);
  }
}
