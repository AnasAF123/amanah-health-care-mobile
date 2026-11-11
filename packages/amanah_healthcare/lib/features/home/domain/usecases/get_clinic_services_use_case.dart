import 'package:amanah_healthcare/core/usecase/use_case.dart';
import 'package:amanah_healthcare/features/home/domain/entities/clinic_service_item.dart';
import 'package:amanah_healthcare/features/home/domain/repositories/clinic_repository.dart';

final class GetClinicServicesUseCase
    implements UseCase<List<ClinicServiceItem>, NoParams> {
  const GetClinicServicesUseCase(this._repository);

  final ClinicRepository _repository;

  @override
  Future<List<ClinicServiceItem>> call(NoParams params) {
    return _repository.getActiveServices();
  }
}
