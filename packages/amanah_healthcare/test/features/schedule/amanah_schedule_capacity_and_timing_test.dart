import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_date_carousel_strip.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_radial_capacity_gauge.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_booked_patient_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/amanah_doctor_session_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/dialogs/amanah_doc_schedule_calendar_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_schedule_capacity_info_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_schedule_detail_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('autoCalculateEndTime - Dynamic Timing Alignment', () {
    test('calculates 09:00 when start time is 08:30 and duration is 30m', () {
      final String result = autoCalculateEndTime(
        '08:30',
        'pagi',
        durationMinutes: 30,
      );
      expect(result, '09:00');
    });

    test('calculates 08:30 when start time is 08:00 and duration is 30m', () {
      final String result = autoCalculateEndTime(
        '08:00',
        'pagi',
        durationMinutes: 30,
      );
      expect(result, '08:30');
    });

    test('calculates 13:45 when start time is 13:00 and duration is 45m', () {
      final String result = autoCalculateEndTime(
        '13:00',
        'siang',
        durationMinutes: 45,
      );
      expect(result, '13:45');
    });

    test('clamps to shift boundary 12:00 when interval exceeds shift end', () {
      final String result = autoCalculateEndTime(
        '11:45',
        'pagi',
        durationMinutes: 30,
      );
      expect(result, '12:00');
    });
  });

  group('AmanahRadialCapacityGauge - Dynamic Slot Denominator', () {
    testWidgets('renders [bookedCount] / [totalSlots] Slot without hardcoded 8', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahRadialCapacityGauge(
              capacityPercentage: 17,
              bookedCount: 2,
              totalSlots: 12,
              isCuti: false,
            ),
          ),
        ),
      );

      // Verify bookedCount
      expect(find.text('2'), findsOneWidget);
      // Verify totalSlots denominator
      expect(find.text(' / 12 Slot'), findsOneWidget);
      // Verify percentage
      expect(find.text('17%'), findsOneWidget);
      expect(find.text('Kapasitas Hari Ini'), findsOneWidget);
    });

    testWidgets('renders cuti badge and 0% when doctor is on cuti', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahRadialCapacityGauge(
              capacityPercentage: 50,
              bookedCount: 2,
              totalSlots: 12,
              isCuti: true,
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
      expect(find.text('Cuti'), findsOneWidget);
      expect(find.text(' / 12 Slot'), findsOneWidget);
    });
  });

  group('AmanahScheduleStore - Capacity Calculation from Created Sessions', () {
    test('calculates capacity percentage from sum of created session capacities', () {
      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.reset();

      final DateTime testDate = DateTime(2026, 9, 25);
      const String key = '2026-09-25';

      // 2 sessions: Morning capacity 8, Afternoon capacity 4 => total 12 slots
      store.schedulesMap[key] = <DoctorSchedule>[
        const DoctorSchedule(
          id: 'sess-1',
          title: 'Sesi Pagi',
          date: '2026-09-25',
          time: '08:00 - 12:00 WIB',
          poli: 'Poli Umum',
          room: 'Ruang 1',
          slotCount: '1',
          slotText: '1 Pasien Booking',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
          capacity: 8,
          bookedPatients: <BookedPatient>[
            BookedPatient(
              id: 'p-1',
              patientName: 'Pasien 1',
              patientAge: '30 Thn',
              patientRm: 'RM-01',
              patientComplaint: 'Keluhan',
              queueNumber: '#01',
              timeSlot: '08:00 - 08:30 WIB',
              badge: 'Aktif',
              badgeVariant: AmanahBadgeVariant.success,
            ),
          ],
        ),
        const DoctorSchedule(
          id: 'sess-2',
          title: 'Sesi Siang',
          date: '2026-09-25',
          time: '13:00 - 15:00 WIB',
          poli: 'Poli Umum',
          room: 'Ruang 1',
          slotCount: '1',
          slotText: '1 Pasien Booking',
          badge: 'Buka',
          badgeVariant: AmanahBadgeVariant.success,
          capacity: 4,
          bookedPatients: <BookedPatient>[
            BookedPatient(
              id: 'p-2',
              patientName: 'Pasien 2',
              patientAge: '25 Thn',
              patientRm: 'RM-02',
              patientComplaint: 'Keluhan 2',
              queueNumber: '#02',
              timeSlot: '13:00 - 13:30 WIB',
              badge: 'Mendatang',
              badgeVariant: AmanahBadgeVariant.primary,
            ),
          ],
        ),
      ];

      // 2 booked patients / 12 total slots = 16.66% -> 17%
      final int percentage = store.getCapacityPercentage(testDate);
      expect(percentage, 17);
    });
  });

  group('isTemporalSlotPast - Slot and Session Expiry Checks', () {
    test('returns true for past dates', () {
      final bool result = isTemporalSlotPast(
        scheduleDateStr: '2026-09-20',
        timeSlotOrEndTime: '08:00 - 08:30 WIB',
        referenceNow: DateTime(2026, 9, 25, 10, 0),
      );
      expect(result, isTrue);
    });

    test('returns false for future dates', () {
      final bool result = isTemporalSlotPast(
        scheduleDateStr: '2026-09-30',
        timeSlotOrEndTime: '08:00 - 08:30 WIB',
        referenceNow: DateTime(2026, 9, 25, 10, 0),
      );
      expect(result, isFalse);
    });

    test('returns true when current time is past slot end time today', () {
      final bool result = isTemporalSlotPast(
        scheduleDateStr: '2026-09-25',
        timeSlotOrEndTime: '08:00 - 08:30 WIB',
        referenceNow: DateTime(2026, 9, 25, 08, 45),
      );
      expect(result, isTrue);
    });

    test('returns false when current time is before slot end time today', () {
      final bool result = isTemporalSlotPast(
        scheduleDateStr: '2026-09-25',
        timeSlotOrEndTime: '08:00 - 08:30 WIB',
        referenceNow: DateTime(2026, 9, 25, 08, 15),
      );
      expect(result, isFalse);
    });
  });

  group('Expired & Disabled Behavior in Cards and Drawers', () {
    const DoctorSchedule pastSession = DoctorSchedule(
      id: 'past-sess-1',
      title: 'Sesi Pagi',
      date: '2026-09-20',
      scheduleDate: '2026-09-20',
      time: '08:00 - 12:00 WIB',
      startTime: '08:00',
      endTime: '12:00',
      poli: 'Poli Umum',
      room: 'Ruang 1',
      slotCount: '1',
      slotText: '1 Pasien Booking',
      badge: 'Buka',
      badgeVariant: AmanahBadgeVariant.success,
    );

    const BookedPatient samplePatient = BookedPatient(
      id: 'p-past-1',
      patientName: 'Pasien Masa Lalu',
      patientAge: '35 Thn',
      patientRm: 'RM-PAST',
      patientComplaint: 'Batuk',
      queueNumber: '#01',
      timeSlot: '08:00 - 08:30 WIB',
      badge: 'Aktif',
      badgeVariant: AmanahBadgeVariant.success,
    );

    testWidgets('AmanahBookedPatientCard renders Selesai badge when slot is expired', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahBookedPatientCard(
              patient: samplePatient,
              schedule: pastSession,
              imageIndex: 0,
              onTapDetail: () {},
            ),
          ),
        ),
      );

      // Matches both status badge 'Selesai' and slot column spec 'Selesai'
      expect(find.text('Selesai'), findsNWidgets(2));
      expect(find.text('Detail Pasien'), findsOneWidget);
    });

    testWidgets('AmanahDoctorSessionCard renders Selesai badge when session is expired', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahDoctorSessionCard(
              schedule: pastSession,
              onTapDetail: () {},
            ),
          ),
        ),
      );

      // Matches both status badge 'Selesai' and slot column spec 'Selesai'
      expect(find.text('Selesai'), findsNWidgets(2));
      expect(find.text('Detail Sesi'), findsOneWidget);
    });

    testWidgets('AmanahScheduleDetailDrawer renders expiration notice when session is expired', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    AmanahScheduleDetailDrawer.show(
                      context,
                      schedule: pastSession,
                      isDayCuti: false,
                      onViewPatients: () {},
                      onTapEdit: () {},
                      onTapDelete: () {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Sesi praktik telah berakhir (Selesai)'), findsOneWidget);
    });

    testWidgets('AmanahDocScheduleCalendarDrawer allows selecting past date if hasSchedules is true', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      final AmanahScheduleStore store = AmanahScheduleStore.instance;
      store.reset();
      store.schedulesMap['2026-09-20'] = <DoctorSchedule>[pastSession];

      DateTime? chosenDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    AmanahDocScheduleCalendarDrawer.show(
                      context,
                      selectedDate: DateTime(2026, 9, 25),
                      baseToday: DateTime(2026, 9, 25),
                      onSelectDate: (DateTime d) => chosenDate = d,
                    );
                  },
                  child: const Text('Open Calendar'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Calendar'));
      await tester.pumpAndSettle();

      // Tap day 20 (which is past date Sep 20, but has schedules)
      final Finder day20Finder = find.text('20');
      expect(day20Finder, findsOneWidget);
      await tester.tap(day20Finder);
      await tester.pumpAndSettle();

      expect(chosenDate, isNotNull);
      expect(chosenDate?.day, 20);
    });

    testWidgets('AmanahRadialCapacityGauge with onTapInfo opens AmanahScheduleCapacityInfoDrawer', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return AmanahRadialCapacityGauge(
                  capacityPercentage: 8,
                  bookedCount: 2,
                  totalSlots: 24,
                  isCuti: false,
                  onTapInfo: () {
                    AmanahScheduleCapacityInfoDrawer.show(
                      context,
                      bookedCount: 2,
                      totalSlots: 24,
                      schedules: const <DoctorSchedule>[pastSession],
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap info icon
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();

      // Verify drawer title and doctor-friendly explanations
      expect(find.text('Informasi Kuota Layanan'), findsOneWidget);
      expect(find.text('Pasien Terdaftar (2)'), findsOneWidget);
      expect(find.text('Total Kuota Layanan (24)'), findsOneWidget);
      expect(find.text('Sisa Kuota Tersedia'), findsOneWidget);
      expect(find.text('22 Slot'), findsOneWidget);
      expect(find.text('Mengerti'), findsOneWidget);
    });

    testWidgets('AmanahBookedPatientCard uses AmanahButton for Detail Pasien', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahBookedPatientCard(
              patient: samplePatient,
              schedule: pastSession,
              imageIndex: 0,
              onTapDetail: () {},
            ),
          ),
        ),
      );

      // Verify that AmanahButton is rendered inside the card
      expect(
        find.descendant(
          of: find.byType(AmanahBookedPatientCard),
          matching: find.byType(AmanahButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('AmanahDateCarouselStrip invokes onDateTap when card is tapped', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.reset());

      DateTime? tappedDate;
      final DateTime today = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AmanahDateCarouselStrip(
              selectedDate: today,
              baseToday: today,
              onSelectDate: (_) {},
              onDateTap: (DateTime d) => tappedDate = d,
              hasSchedulesForDate: (_) => true,
              isCutiForDate: (_) => false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on day 25
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();

      expect(tappedDate, isNotNull);
      expect(tappedDate?.day, 25);
    });
  });
}
