import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/patient_record/data/datasources/intake_remote_data_source.dart';
import 'package:amanah_healthcare/features/patient_record/data/mappers/patient_intake_mapper.dart';
import 'package:amanah_healthcare/features/patient_record/domain/entities/patient_intake_record.dart';
import 'package:amanah_healthcare/features/patient_record/domain/failures/intake_failure.dart';
import 'package:amanah_healthcare/features/patient_record/domain/repositories/intake_repository.dart';

class IntakeRepositoryImpl implements IntakeRepository {
  IntakeRepositoryImpl({
    IntakeRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? IntakeRemoteDataSourceImpl();

  final IntakeRemoteDataSource _remoteDataSource;

  @override
  Future<PatientIntakeRecord> getIntakeByAppointmentId(
    String appointmentId,
  ) async {
    try {
      final dynamic raw =
          await _remoteDataSource.getIntakeByAppointmentId(appointmentId);
      if (raw is Map<String, dynamic>) {
        return PatientIntakeMapper.fromJson(raw, appointmentId);
      }
      throw const IntakeFailure('Format data intake tidak valid dari server');
    } on NotFoundException catch (e) {
      throw IntakeNotFoundFailure(e.message, e.code);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        throw IntakeNotFoundFailure(e.message, e.code);
      }
      throw IntakeFailure(e.message, code: e.code);
    } on IntakeFailure {
      rethrow;
    } catch (e) {
      throw IntakeFailure('Gagal memuat data formulir pasien: $e');
    }
  }
}
