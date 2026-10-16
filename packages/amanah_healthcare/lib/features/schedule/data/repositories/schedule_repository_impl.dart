import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/schedule/data/datasources/schedule_remote_data_source.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/calendar_summary_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/my_schedule_session_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/session_patient_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/update_doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/calendar_summary_mapper.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/doctor_roster_mapper.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/my_schedule_session_mapper.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/session_patient_mapper.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/calendar_day_summary.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/domain/failures/schedule_failure.dart';
import 'package:amanah_healthcare/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({
    ScheduleRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ScheduleRemoteDataSourceImpl();

  final ScheduleRemoteDataSource _remoteDataSource;

  Never _handleError(Object error) {
    if (error is NetworkException) {
      throw ScheduleNetworkFailure(error.message);
    }
    if (error is UnauthorizedException) {
      throw ScheduleUnauthorizedFailure(error.message);
    }
    if (error is NotFoundException) {
      throw ScheduleNotFoundFailure(error.message);
    }
    if (error is ServerException) {
      throw ScheduleServerFailure(error.message, error.code);
    }
    if (error is AmanahScheduleException) {
      throw error;
    }
    throw ScheduleServerFailure(error.toString());
  }

  @override
  Future<DoctorRoster> getDoctorRoster() async {
    try {
      final DoctorRosterOverviewDto dto =
          await _remoteDataSource.getDoctorRoster();
      return DoctorRosterMapper.fromDto(dto);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<DoctorRoster> updateDoctorRoster(
    List<Map<String, dynamic>> assignments, {
    String? reason,
  }) async {
    try {
      final List<UpdateDoctorRosterAssignmentDto> assignmentDtos = assignments
          .map(
            (Map<String, dynamic> item) => UpdateDoctorRosterAssignmentDto(
              dow: item['dow'] as int? ?? 0,
              sessionId: item['sessionId'] as String? ?? '',
              isActive: item['isActive'] as bool? ?? false,
              preferredRoomId: item['preferredRoomId'] as String?,
            ),
          )
          .toList();

      final UpdateDoctorRosterDto payload = UpdateDoctorRosterDto(
        assignments: assignmentDtos,
        reason: reason,
      );

      final DoctorRosterOverviewDto res =
          await _remoteDataSource.updateDoctorRoster(payload);
      return DoctorRosterMapper.fromDto(res);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<DoctorRoster> resetDoctorRoster() async {
    try {
      final DoctorRosterOverviewDto res =
          await _remoteDataSource.resetDoctorRoster();
      return DoctorRosterMapper.fromDto(res);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<CalendarDaySummary>> getCalendarSummary(String month) async {
    try {
      final CalendarSummaryResponseDto res =
          await _remoteDataSource.getCalendarSummary(month);
      return res.days.map(CalendarSummaryMapper.fromDto).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<SessionPatient>> getBookedPatients(String date) async {
    try {
      final List<SessionPatientDto> dtos =
          await _remoteDataSource.getBookedPatients(date);
      return dtos.map(SessionPatientMapper.fromDto).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<SessionPatient>> getSessionPatients(
    String sessionId, {
    String? date,
  }) async {
    try {
      final List<SessionPatientDto> dtos =
          await _remoteDataSource.getSessionPatients(sessionId, date: date);
      return dtos.map(SessionPatientMapper.fromDto).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<MyScheduleSession>> getMySchedules({
    String? date,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final List<MyScheduleSessionDto> dtos =
          await _remoteDataSource.getMySchedules(
        date: date,
        startDate: startDate,
        endDate: endDate,
      );
      return dtos.map(MyScheduleSessionMapper.fromDto).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> toggleDayStatus(
    String date, {
    required bool isClosed,
    String? notes,
  }) async {
    try {
      await _remoteDataSource.toggleDayStatus(
        date,
        isClosed: isClosed,
        notes: notes,
      );
    } catch (e) {
      _handleError(e);
    }
  }
}
