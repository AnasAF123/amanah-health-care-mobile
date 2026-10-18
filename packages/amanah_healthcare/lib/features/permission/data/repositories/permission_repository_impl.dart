import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/permission/data/datasources/permission_remote_data_source.dart';
import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/data/mappers/permission_mapper.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/failures/permission_failure.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl({
    PermissionRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
            remoteDataSource ?? PermissionRemoteDataSourceImpl();

  final PermissionRemoteDataSource _remoteDataSource;

  Never _handleError(Object error) {
    if (error is NetworkException) {
      throw PermissionNetworkFailure(error.message);
    }
    if (error is UnauthorizedException) {
      throw PermissionUnauthorizedFailure(error.message);
    }
    if (error is NotFoundException) {
      throw PermissionNotFoundFailure(error.message);
    }
    if (error is ServerException) {
      throw PermissionServerFailure(error.message, error.code);
    }
    if (error is AmanahPermissionException) {
      throw error;
    }
    throw PermissionServerFailure(error.toString());
  }

  @override
  Future<List<EligibleSession>> getEligibleSessions(String date) async {
    try {
      final List<EligibleSessionDto> dtos =
          await _remoteDataSource.getEligibleSessions(date);
      return dtos.map(PermissionMapper.toEligibleSession).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<LeaveRequestEntity> requestLeave({
    required String startDate,
    required String endDate,
    required String reason,
    String? type,
    String? scope,
    List<String>? sessionIds,
  }) async {
    try {
      final LeaveRequestDto dto = await _remoteDataSource.requestLeave(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        type: type,
        scope: scope,
        sessionIds: sessionIds,
      );
      return PermissionMapper.toLeaveRequestEntity(dto);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<LeaveRequestEntity>> getMyLeaves() async {
    try {
      final List<LeaveRequestDto> dtos = await _remoteDataSource.getMyLeaves();
      return dtos.map(PermissionMapper.toLeaveRequestEntity).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<LeaveRequestEntity> cancelLeave(String id) async {
    try {
      final LeaveRequestDto dto = await _remoteDataSource.cancelLeave(id);
      return PermissionMapper.toLeaveRequestEntity(dto);
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<ReplacementItem>> getAvailableReplacements() async {
    try {
      final List<ReplacementItemDto> dtos =
          await _remoteDataSource.getAvailableReplacements();
      return dtos.map(PermissionMapper.toReplacementItem).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ReplacementItem> claimReplacement(String id) async {
    try {
      final ReplacementItemDto dto =
          await _remoteDataSource.claimReplacement(id);
      return PermissionMapper.toReplacementItem(dto);
    } catch (e) {
      _handleError(e);
    }
  }
}
