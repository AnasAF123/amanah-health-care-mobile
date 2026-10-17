import 'package:flutter/foundation.dart';
import 'package:amanah_healthcare/features/patient_record/data/repositories/intake_repository_impl.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/failures/intake_failure.dart';
import 'package:amanah_healthcare/features/patient_record/domain/usecases/get_appointment_intake_use_case.dart';

enum IntakeStateStatus { initial, loading, loaded, empty, error }

class PatientIntakeController extends ChangeNotifier {
  PatientIntakeController({
    GetAppointmentIntakeUseCase? getIntakeUseCase,
  }) : _getIntakeUseCase = getIntakeUseCase ??
            GetAppointmentIntakeUseCase(IntakeRepositoryImpl());

  final GetAppointmentIntakeUseCase _getIntakeUseCase;

  IntakeStateStatus _status = IntakeStateStatus.initial;
  PatientIntakeRecord? _intake;
  String? _errorMessage;

  IntakeStateStatus get status => _status;
  bool get isLoading => _status == IntakeStateStatus.loading;
  bool get isEmpty => _status == IntakeStateStatus.empty;
  PatientIntakeRecord? get intake => _intake;
  String? get errorMessage => _errorMessage;

  Future<void> loadIntake(String appointmentId) async {
    _status = IntakeStateStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final PatientIntakeRecord res = await _getIntakeUseCase(appointmentId);
      _intake = res;
      _status = IntakeStateStatus.loaded;
    } on IntakeNotFoundFailure {
      _intake = null;
      _status = IntakeStateStatus.empty;
    } catch (e) {
      _errorMessage = e.toString();
      _status = IntakeStateStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
