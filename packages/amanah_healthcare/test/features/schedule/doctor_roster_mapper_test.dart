import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/data/dto/doctor_roster_dto.dart';
import 'package:amanah_healthcare/features/schedule/data/mappers/doctor_roster_mapper.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/domain/helpers/clinical_session_resolver.dart';

void main() {
  group('DoctorRosterMapper', () {
    test('maps DoctorRosterOverviewDto to DoctorRoster entity correctly', () {
      final DoctorRosterOverviewDto dto = DoctorRosterOverviewDto(
        doctorId: 'doc-123',
        doctorName: 'dr. Andi Pratama',
        specialization: 'Dokter Umum',
        hasAnyOverride: true,
        days: <DoctorRosterDayDto>[
          DoctorRosterDayDto(
            dow: 1,
            dayCode: 'monday',
            dayName: 'Senin',
            sortOrder: 1,
            isWeekend: false,
            isOperatingDay: true,
            isDoctorActive: true,
            hasOverride: true,
            sessions: <DoctorRosterSessionDto>[
              DoctorRosterSessionDto(
                sessionId: 'sess-morning',
                sessionCode: 'morning',
                sessionLabel: ClinicalSessionShift.morning.displaySessionName,
                timeRange: '08:00 - 12:00',
                isActive: true,
                isTemplateActive: true,
                preferredRoomId: 'room-1',
                preferredRoomName: 'Ruang 101',
              ),
              DoctorRosterSessionDto(
                sessionId: 'sess-night',
                sessionCode: 'night',
                sessionLabel: ClinicalSessionShift.night.displaySessionName,
                timeRange: '19:00 - 22:00',
                isActive: false,
                isTemplateActive: false,
              ),
            ],
          ),
        ],
      );

      final DoctorRoster entity = DoctorRosterMapper.fromDto(dto);

      expect(entity.doctorId, 'doc-123');
      expect(entity.doctorName, 'dr. Andi Pratama');
      expect(entity.specialization, 'Dokter Umum');
      expect(entity.hasAnyOverride, true);
      expect(entity.days.length, 1);

      final DoctorRosterDay day = entity.days.first;
      expect(day.dow, 1);
      expect(day.dayName, 'Senin');
      expect(day.sessions.length, 2);

      final DoctorRosterSession session1 = day.sessions[0];
      expect(session1.sessionId, 'sess-morning');
      expect(session1.sessionCode, 'morning');
      expect(session1.sessionLabel, ClinicalSessionShift.morning.displaySessionName);
      expect(session1.isActive, true);
      expect(session1.preferredRoomName, 'Ruang 101');

      final DoctorRosterSession session2 = day.sessions[1];
      expect(session2.isActive, false);
      expect(session2.preferredRoomName, isNull);
    });

    test('DoctorRosterSessionDto.fromJson normalizes i18n keys to canonical display name', () {
      final DoctorRosterSessionDto dto = DoctorRosterSessionDto.fromJson(<String, dynamic>{
        'sessionId': 'sess-1',
        'sessionCode': 'morning',
        'sessionLabel': 'session.morning',
        'timeRange': '06:00 - 12:00',
        'isActive': true,
      });
      expect(dto.sessionLabel, ClinicalSessionShift.morning.displaySessionName);
    });
  });
}
