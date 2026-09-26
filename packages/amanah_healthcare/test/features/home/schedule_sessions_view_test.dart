import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_sessions_view.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_doctor_session_card.dart';

void main() {
  testWidgets(
    'AmanahScheduleSessionsView renders exactly one card per session regardless of occupancy overview slots',
    (WidgetTester tester) async {
      final DayScheduleSetting daySetting = DayScheduleSetting(
        scheduleDate: '2026-09-26',
        targetQuota: 8,
        isCuti: false,
        totalBookedPatients: 0,
        capacityPercentage: 0,
      );

      // One session returned by /api/v1/schedules/my-schedules
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

      // Occupancy overview with 2 OCCUPIED_BY_SELF slots both pointing to the
      // same session. Previously the view incorrectly produced 2 synthetic cards
      // (one per slot). The correct behavior is 1 card per session in rawSchedules.
      final ScheduleOccupancyOverviewData occupancyOverview =
          ScheduleOccupancyOverviewData(
        date: '2026-09-26',
        summary: const ScheduleOccupancySummary(
          totalShifts: 4,
          totalSlots: 48,
          availableSlots: 46,
          occupiedSlots: 2,
        ),
        shifts: <ScheduleShiftOccupancy>[
          // Unscheduled morning shift — must NOT be rendered
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
          // Doctor's night shift with 2 sub-slots for the same session
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

      // The authoritative list has 1 session → exactly 1 card must be rendered.
      // Two OCCUPIED_BY_SELF sub-slots in the occupancy grid both refer to the
      // same session-night-1; they must not produce duplicate cards.
      expect(find.byType(AmanahDoctorSessionCard), findsOneWidget);

      // The card renders startTime and endTime as separate Text widgets.
      // Verify the session-level times from rawSchedules are shown.
      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('24:00'), findsOneWidget);

      // Morning shift (unscheduled) is NOT rendered
      expect(find.text('06:00'), findsNothing);
    },
  );

  testWidgets(
    'AmanahScheduleSessionsView renders all sessions when multiple sessions exist in the same shift',
    (WidgetTester tester) async {
      final DayScheduleSetting daySetting = DayScheduleSetting(
        scheduleDate: '2026-09-26',
        targetQuota: 8,
        isCuti: false,
      );

      // Two distinct sessions both in the morning shift.
      // Previously the occupancy-grid path collapsed these into 1 synthetic card
      // because the grid only has 1 OCCUPIED_BY_SELF slot for the morning shift.
      final List<DoctorSchedule> rawSchedules = <DoctorSchedule>[
        const DoctorSchedule(
          id: 'session-morning-1',
          title: 'Sesi Pagi 1',
          date: '2026-09-26',
          time: '07:00 - 08:00 WIB',
          poli: 'Poli Umum',
          room: 'Ruang A',
          slotCount: '0',
          slotText: '0 Pasien Booking',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
          startTime: '07:00',
          endTime: '08:00',
          sessionShift: 'morning',
          sessionType: 'Pagi',
        ),
        const DoctorSchedule(
          id: 'session-morning-2',
          title: 'Sesi Pagi 2',
          date: '2026-09-26',
          time: '09:00 - 10:00 WIB',
          poli: 'Poli Bedah',
          room: 'Ruang B',
          slotCount: '0',
          slotText: '0 Pasien Booking',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
          startTime: '09:00',
          endTime: '10:00',
          sessionShift: 'morning',
          sessionType: 'Pagi',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AmanahScheduleSessionsView(
                daySetting: daySetting,
                isCuti: false,
                schedules: rawSchedules,
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

      // Both sessions must be rendered — 2 cards for 2 sessions.
      expect(find.byType(AmanahDoctorSessionCard), findsNWidgets(2));
      // The card renders startTime and endTime as separate Text widgets.
      expect(find.text('07:00'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
    },
  );

  testWidgets(
    'AmanahScheduleSessionsView disables past date slots and shows Selesai even if status is Buka',
    (WidgetTester tester) async {
      final DateTime pastDate = DateTime(2026, 9, 24);
      final DayScheduleSetting daySetting = DayScheduleSetting(
        scheduleDate: '2026-09-24',
        targetQuota: 8,
        isCuti: false,
        status: 'OPEN',
        isClosed: false,
      );

      // Backend returned schedule with status OPEN and isAvailable true on a past date
      final List<DoctorSchedule> pastSchedules = <DoctorSchedule>[
        const DoctorSchedule(
          id: 'past-session-1',
          title: 'Sesi Siang',
          date: '2026-09-24',
          scheduleDate: '2026-09-24',
          time: '13:00 - 13:30 WIB',
          poli: 'Poli Umum',
          room: 'Ruang Poli Umum 1',
          slotCount: '0',
          slotText: '0 Pasien Booking',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
          startTime: '13:00',
          endTime: '13:30',
          sessionShift: 'afternoon',
          sessionType: 'Siang',
          isAvailable: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AmanahScheduleSessionsView(
                selectedDate: pastDate,
                daySetting: daySetting,
                isCuti: false,
                schedules: pastSchedules,
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

      // Verify card is rendered
      expect(find.byType(AmanahDoctorSessionCard), findsOneWidget);

      // Crucial: The badge is 'Selesai' and the time column label is also 'Selesai' (2 widgets), and 'Buka' is gone
      expect(find.text('Selesai'), findsNWidgets(2));
      expect(find.text('Buka'), findsNothing);
    },
  );
}
