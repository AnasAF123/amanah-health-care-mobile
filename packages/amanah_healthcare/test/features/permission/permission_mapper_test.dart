import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/permission/data/dto/eligible_session_dto.dart';
import 'package:amanah_healthcare/features/permission/data/mappers/permission_mapper.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';

void main() {
  group('PermissionMapper Backend Session Sanitization', () {
    test('Maps raw backend session keys to clean Indonesian labels and normalizes times', () {
      const EligibleSessionDto morningDto = EligibleSessionDto(
        sessionId: 'sess-1',
        sessionCode: 'morning',
        sessionLabel: 'session.morning',
        startsAt: '06:00:00',
        endsAt: '12:00:00',
        workDate: '2026-10-19',
      );

      final EligibleSession morning = PermissionMapper.toEligibleSession(morningDto);
      expect(morning.sessionLabel, 'Sesi Pagi');
      expect(morning.startsAt, '06:00');
      expect(morning.endsAt, '12:00');

      const EligibleSessionDto afternoonDto = EligibleSessionDto(
        sessionId: 'sess-2',
        sessionCode: 'afternoon',
        sessionLabel: 'session.afternoon',
        startsAt: '12:00:00',
        endsAt: '18:00:00',
        workDate: '2026-10-19',
      );

      final EligibleSession afternoon = PermissionMapper.toEligibleSession(afternoonDto);
      expect(afternoon.sessionLabel, 'Sesi Siang');
      expect(afternoon.startsAt, '12:00');
      expect(afternoon.endsAt, '18:00');

      const EligibleSessionDto nightDto = EligibleSessionDto(
        sessionId: 'sess-3',
        sessionCode: 'night',
        sessionLabel: 'session.night',
        startsAt: '18:00:00',
        endsAt: '24:00:00',
        workDate: '2026-10-19',
      );

      final EligibleSession night = PermissionMapper.toEligibleSession(nightDto);
      expect(night.sessionLabel, 'Sesi Malam');
      expect(night.startsAt, '18:00');
      expect(night.endsAt, '24:00');
    });

    test('Falls back to resolving sessionShift when sessionLabel is raw code', () {
      const EligibleSessionDto fallbackDto = EligibleSessionDto(
        sessionId: 'sess-4',
        sessionCode: 'afternoon',
        sessionLabel: 'SIANG',
        startsAt: '12:00',
        endsAt: '18:00',
        workDate: '2026-10-19',
      );

      final EligibleSession result = PermissionMapper.toEligibleSession(fallbackDto);
      expect(result.sessionLabel, 'Sesi Siang');
    });
  });
}
