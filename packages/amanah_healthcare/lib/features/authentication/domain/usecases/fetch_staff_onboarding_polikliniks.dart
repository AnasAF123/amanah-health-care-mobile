import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/authentication/domain/repositories/auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';

class FetchStaffOnboardingPolikliniksUseCase
    implements UseCase<List<StaffOnboardingPoliOption>, NoParams> {
  const FetchStaffOnboardingPolikliniksUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<List<StaffOnboardingPoliOption>> call(NoParams params) {
    return _repository.fetchStaffOnboardingPolikliniks();
  }
}
