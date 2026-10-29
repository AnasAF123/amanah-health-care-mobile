import 'package:amanah_healthcare/core/network/api_exception.dart';
import 'package:amanah_healthcare/features/permission/data/datasources/permission_remote_data_source.dart';
import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/leave_request_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_facets_dto.dart';
import 'package:amanah_healthcare/features/permission/data/dto/replacement_item_dto.dart';
import 'package:amanah_healthcare/features/permission/data/mappers/permission_mapper.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/amanah_permission_form_data.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/domain/failures/permission_failure.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl({PermissionRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? PermissionRemoteDataSourceImpl();

  final PermissionRemoteDataSource _remoteDataSource;

  Never _handleError(Object error) {
    if (error is BadRequestException) {
      throw PermissionValidationFailure(error.message, code: error.code);
    }
    if (error is ForbiddenException) {
      throw PermissionUnauthorizedFailure(error.message);
    }
    if (error is ConflictException) {
      throw PermissionServerFailure(error.message, error.code);
    }
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
      final List<EligibleSessionDto> dtos = await _remoteDataSource.getEligibleSessions(date);
      return dtos.map(PermissionMapper.toEligibleSession).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<LeaveRequestEntity> requestLeave(AmanahPermissionFormData formData) async {
    try {
      final LeaveRequestDto dto = await _remoteDataSource.requestLeave(
        startDate: formData.startDate,
        endDate: formData.endDate,
        reason: formData.reason,
        type: PermissionMapper.mapPermissionTypeToApi(formData.type),
        scope: formData.scope,
        sessionIds: formData.sessionIds,
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
  Future<List<ReplacementItem>> getAvailableReplacements({
    String? exactDate,
    String? staffProfileId,
  }) async {
    try {
      final List<ReplacementItemDto> dtos = await _remoteDataSource.getAvailableReplacements(
        exactDate: exactDate,
        staffProfileId: staffProfileId,
      );
      return dtos.map(PermissionMapper.toReplacementItem).toList();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ReplacementFacets> getReplacementFacets() async {
    try {
      final ReplacementFacetsDto dto = await _remoteDataSource.getReplacementFacets();
      return dto.toEntity();
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ReplacementItem> claimReplacement(String id) async {
    try {
      final ReplacementItemDto dto = await _remoteDataSource.claimReplacement(id);
      return PermissionMapper.toReplacementItem(dto);
    } catch (e) {
      _handleError(e);
    }
  }
}
