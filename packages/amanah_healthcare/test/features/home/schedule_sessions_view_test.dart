import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_sessions_view.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_doctor_session_card.dart';

void main() {
  testWidgets('AmanahScheduleSessionsView renders only doctor scheduled slots and disables past slots', (WidgetTester tester) async {
    final DayScheduleSetting daySetting = DayScheduleSetting(
      scheduleDate: '2026-09-26',
      targetQuota: 8,
      isCuti: false,
      totalBookedPatients: 0,
      capacityPercentage: 0,
    );

    // Raw overview schedule from my-schedules: 18:00 - 24:00
    final List<DoctorSchedule> rawSchedules = <DoctorSchedule>[
      const DoctorSchedule(
        id: 'session-night-1',
        title: 'Sesi Malam',
        date: '2026-09-26',
        time: '18:00 - 24:00 WIB',
        poli: 'Poli Umum',
        room: 'Ruang Poli Umum 1',
        slotCount: '0',
        slotText: '0 Pasien Booking',
        badge: 'Buka',
        badgeVariant: AmanahBadgeVariant.success,
        startTime: '18:00',
        endTime: '24:00',
        sessionShift: 'night',
        sessionType: 'Malam',
      ),
    ];

    // Occupancy overview with 1 past slot, 1 future slot, and available unscheduled slots
    final ScheduleOccupancyOverviewData occupancyOverview = ScheduleOccupancyOverviewData(
      date: '2026-09-26',
      summary: const ScheduleOccupancySummary(
        totalShifts: 4,
        totalSlots: 48,
        availableSlots: 46,
        occupiedSlots: 2,
      ),
      shifts: <ScheduleShiftOccupancy>[
        // Shift with available slots (not scheduled by doctor) -> should not be rendered
        const ScheduleShiftOccupancy(
          shift: 'morning',
          shiftLabel: 'Pagi',
          timeRange: '06:00 - 12:00 WIB',
          boundaryStartTime: '06:00',
          boundaryEndTime: '12:00',
          slotDurationMinutes: 30,
          totalSlots: 12,
          availableSlotsCount: 12,
          occupiedSlotsCount: 0,
          slots: <ScheduleShiftSlot>[
            ScheduleShiftSlot(
              slotIndex: 1,
              startTime: '06:00',
              endTime: '06:30',
              timeRange: '06:00 - 06:30 WIB',
              isAvailable: true,
              status: 'AVAILABLE',
              displayLabel: 'Tersedia',
            ),
          ],
        ),
        // Shift with doctor's scheduled slots
        const ScheduleShiftOccupancy(
          shift: 'night',
          shiftLabel: 'Malam',
          timeRange: '18:00 - 24:00 WIB',
          boundaryStartTime: '18:00',
          boundaryEndTime: '24:00',
          slotDurationMinutes: 30,
          totalSlots: 12,
          availableSlotsCount: 10,
          occupiedSlotsCount: 2,
          slots: <ScheduleShiftSlot>[
            ScheduleShiftSlot(
              slotIndex: 1,
              startTime: '18:00',
              endTime: '18:30',
              timeRange: '18:00 - 18:30 WIB',
              isAvailable: false,
              status: 'OCCUPIED_BY_SELF',
              displayLabel: 'Jadwal Anda (Ruang Poli Umum 1)',
              conflictInfo: ScheduleSlotConflictInfo(
                type: 'SELF',
                message: 'Jadwal Anda',
                sessionId: 'session-night-1',
                roomName: 'Ruang Poli Umum 1',
              ),
            ),
            ScheduleShiftSlot(
              slotIndex: 2,
              startTime: '18:30',
              endTime: '19:00',
              timeRange: '18:30 - 19:00 WIB',
              isAvailable: false,
              status: 'OCCUPIED_BY_SELF',
              displayLabel: 'Jadwal Anda (Ruang Poli Umum 1)',
              conflictInfo: ScheduleSlotConflictInfo(
                type: 'SELF',
                message: 'Jadwal Anda',
                sessionId: 'session-night-1',
                roomName: 'Ruang Poli Umum 1',
              ),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AmanahScheduleSessionsView(
              daySetting: daySetting,
              isCuti: false,
              schedules: rawSchedules,
              occupancyOverview: occupancyOverview,
              dark: false,
              onTapDetail: (_) {},
              onTapEdit: (_) {},
              onTapDelete: (_) {},
              onOpenAddSchedule: () {},
            ),
          ),
        ),
      ),
    );

    // Verify: exactly 2 cards are rendered (only the 2 OCCUPIED_BY_SELF slots)
    expect(find.byType(AmanahDoctorSessionCard), findsNWidgets(2));

    // Verify times rendered on cards: 18:00 -> 18:30, and 18:30 -> 19:00
    expect(find.text('18:00'), findsOneWidget);
    expect(find.text('18:30'), findsNWidgets(2)); // endTime of slot 1 & startTime of slot 2
    expect(find.text('19:00'), findsOneWidget);

    // The old 24:00 6-hour shift end time is NOT rendered
    expect(find.text('24:00'), findsNothing);

    // The available morning slot is NOT rendered
    expect(find.text('06:00'), findsNothing);
  });
}
