import 'package:amanah_healthcare/features/schedule/data/dto/my_schedule_session_dto.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';

abstract final class MyScheduleSessionMapper {
  static MyScheduleSession fromDto(MyScheduleSessionDto dto) {
    return MyScheduleSession(
      id: dto.id,
      sessionId: dto.sessionId,
      sessionCode: dto.sessionCode,
      sessionLabel: dto.sessionLabel,
      scheduleDate: dto.scheduleDate,
      startTime: dto.startTime,
      endTime: dto.endTime,
      timeRange: dto.timeRange,
      roomName: dto.roomName,
      poliklinikName: dto.poliklinikName,
      status: dto.status,
      isAvailable: dto.isAvailable,
      bookedCount: dto.bookedCount,
      maxQuota: dto.maxQuota,
    );
  }
}
