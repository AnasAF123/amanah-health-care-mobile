import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_slot_occupied_detail_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/amanah_schedule_selection_sheet.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_session_panel.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_target_selectors.dart';

void main() {
  group('isSessionShiftPast Logic Tests', () {
    final DateTime today = DateTime(2026, 9, 25, 18, 57); // 18:57 WIB (malam)
    final DateTime tomorrow = DateTime(2026, 9, 26, 8, 0);

    test('Today at 18:57 disables past dini hari, morning and afternoon sessions, keeps evening open', () {
      // Dini Hari (ends 06:00) -> past
      expect(
        isSessionShiftPast(
          sessionId: 'dini_hari',
          selectedDate: DateTime(2026, 9, 25),
          referenceNow: today,
        ),
        isTrue,
      );

      // Pagi (ends 12:00) -> past
      expect(
        isSessionShiftPast(
          sessionId: 'pagi',
          selectedDate: DateTime(2026, 9, 25),
          referenceNow: today,
        ),
        isTrue,
      );

      // Siang (ends 17:00) -> past
      expect(
        isSessionShiftPast(
          sessionId: 'siang',
          selectedDate: DateTime(2026, 9, 25),
          referenceNow: today,
        ),
        isTrue,
      );

      // Malam (ends 21:00) -> NOT past (eligible)
      expect(
        isSessionShiftPast(
          sessionId: 'malam',
          selectedDate: DateTime(2026, 9, 25),
          referenceNow: today,
        ),
        isFalse,
      );
    });

    test('Tomorrow date has all sessions active and open', () {
      expect(
        isSessionShiftPast(
          sessionId: 'pagi',
          selectedDate: tomorrow,
          referenceNow: today,
        ),
        isFalse,
      );
      expect(
        isSessionShiftPast(
          sessionId: 'siang',
          selectedDate: tomorrow,
          referenceNow: today,
        ),
        isFalse,
      );
      expect(
        isSessionShiftPast(
          sessionId: 'malam',
          selectedDate: tomorrow,
          referenceNow: today,
        ),
        isFalse,
      );
      expect(
        isSessionShiftPast(
          sessionId: 'dini_hari',
          selectedDate: tomorrow,
          referenceNow: today,
        ),
        isFalse,
      );
    });
  });

  group('ScheduleSessionPanel isPast Tests', () {
    testWidgets('Session panel with isPast = true is disabled from parent and shows Sudah Selesai', (WidgetTester tester) async {
      bool toggled = false;
      const ScheduleFormSession session = ScheduleFormSession(
        id: 'pagi',
        name: 'Sesi Pagi',
        sessionType: 'Pagi',
        active: false,
        slots: <ScheduleFormSlot>[],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleSessionPanel(
              session: session,
              dark: false,
              isPast: true,
              onToggle: (bool val) => toggled = true,
              onSlotChanged: ({required int slotIndex, String? from, String? to, String? room, String? poli}) {},
              onAddSlot: () {},
              onRemoveSlot: (int index) {},
              onOpenSelection: ({
                required String title,
                required String subtitle,
                required String currentValue,
                required List<String> options,
                required ValueChanged<String> onChanged,
                List<String> disabledOptions = const <String>[],
                Map<String, String> optionSubtitles = const <String, String>{},
                Map<String, SlotOccupiedInfo> occupiedDetails = const <String, SlotOccupiedInfo>{},
                String? sessionId,
                bool isTimePicker = false,
              }) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Sudah Selesai'), findsOneWidget);

      // Attempt to tap the panel
      await tester.tap(find.text('Sesi Pagi'));
      await tester.pumpAndSettle();

      // Should NOT toggle because it is past
      expect(toggled, isFalse);
    });

    testWidgets('Session panel with isUnavailable = true is disabled and shows Penuh badge', (WidgetTester tester) async {
      bool toggled = false;
      const ScheduleFormSession session = ScheduleFormSession(
        id: 'malam',
        name: 'Sesi Malam',
        sessionType: 'Malam',
        active: false,
        slots: <ScheduleFormSlot>[],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleSessionPanel(
              session: session,
              dark: false,
              isUnavailable: true,
              unavailableReason: 'Penuh',
              onToggle: (bool val) => toggled = true,
              onSlotChanged: ({required int slotIndex, String? from, String? to, String? room, String? poli}) {},
              onAddSlot: () {},
              onRemoveSlot: (int index) {},
              onOpenSelection: ({
                required String title,
                required String subtitle,
                required String currentValue,
                required List<String> options,
                required ValueChanged<String> onChanged,
                List<String> disabledOptions = const <String>[],
                Map<String, String> optionSubtitles = const <String, String>{},
                Map<String, SlotOccupiedInfo> occupiedDetails = const <String, SlotOccupiedInfo>{},
                String? sessionId,
                bool isTimePicker = false,
              }) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Penuh'), findsOneWidget);

      // Attempt to tap the panel
      await tester.tap(find.text('Sesi Malam'));
      await tester.pumpAndSettle();

      // Should NOT toggle because it is unavailable
      expect(toggled, isFalse);
    });
  });

  group('isSessionShiftUnavailable Logic Tests', () {
    final DateTime testDate = DateTime(2026, 9, 25);
    final DateTime at2236 = DateTime(2026, 9, 25, 22, 36);

    test('Shift with 0 available slots in occupancy is unavailable', () {
      const ScheduleShiftOccupancy fullOcc = ScheduleShiftOccupancy(
        shift: 'malam',
        shiftLabel: 'Malam',
        timeRange: '18:00 - 24:00 WIB',
        boundaryStartTime: '18:00',
        boundaryEndTime: '24:00',
        slotDurationMinutes: 30,
        totalSlots: 12,
        availableSlotsCount: 0,
        occupiedSlotsCount: 12,
        slots: <ScheduleShiftSlot>[],
      );

      final bool unavailable = isSessionShiftUnavailable(
        sessionId: 'malam',
        selectedDate: testDate,
        occupancy: fullOcc,
      );

      expect(unavailable, isTrue);
    });

    test('Ongoing shift with remaining time < consultation duration is unavailable', () {
      // Sesi with boundary ending at 23:00 (1380m). At 22:36 (1356m), 24m remaining < 30m
      final bool unavailable = isSessionShiftUnavailable(
        sessionId: 'malam',
        selectedDate: testDate,
        referenceNow: at2236,
        context: ScheduleContext.fromJson(const <String, dynamic>{
          'contextId': 'ctx-night',
          'contextLabel': 'Malam',
          'sessionShift': 'malam',
          'boundaryStartTime': '18:00',
          'boundaryEndTime': '23:00',
          'effectiveConsultationDurationMinutes': 30,
        }),
      );

      expect(unavailable, isTrue);
    });

    test('When editing existing schedule on this session, isUnavailable remains false if not past', () {
      const ScheduleShiftOccupancy fullOcc = ScheduleShiftOccupancy(
        shift: 'malam',
        shiftLabel: 'Malam',
        timeRange: '18:00 - 24:00 WIB',
        boundaryStartTime: '18:00',
        boundaryEndTime: '24:00',
        slotDurationMinutes: 30,
        totalSlots: 12,
        availableSlotsCount: 0,
        occupiedSlotsCount: 12,
        slots: <ScheduleShiftSlot>[],
      );

      final bool unavailable = isSessionShiftUnavailable(
        sessionId: 'malam',
        selectedDate: DateTime(2026, 9, 26),
        occupancy: fullOcc,
        isEditingThisSession: true,
      );

      expect(unavailable, isFalse);
    });
  });

  group('AmanahScheduleSelectionSheet & AmanahSlotOccupiedDetailDrawer Tests', () {
    testWidgets('Disabled option is never marked as selected even if currentValue matches', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahScheduleSelectionSheet(
              title: 'Pilih Waktu Mulai',
              subtitle: 'Batas shift: 07:00 - 12:00 WIB',
              currentValue: '08:00',
              options: <String>['07:30', '08:00', '08:30'],
              disabledOptions: <String>['08:00'],
              isTimePicker: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Checkmark icon should not be present because '08:00' is disabled
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('Tapping disabled option triggers minimalist AmanahSlotOccupiedDetailDrawer', (WidgetTester tester) async {
      final Map<String, SlotOccupiedInfo> occupied = <String, SlotOccupiedInfo>{
        '08:00': const SlotOccupiedInfo(
          time: '08:00',
          timeRange: '08:00 - 08:30 WIB',
          statusLabel: 'Telah Digunakan',
          occupiedBy: 'dr. Budi Santoso, Sp.A',
          poliName: 'Poli Anak',
          roomName: 'Ruang 102',
          reason: 'Slot waktu ini telah dialokasikan untuk jadwal praktik dokter lain.',
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext ctx) => AmanahScheduleSelectionSheet(
                      title: 'Pilih Waktu Mulai',
                      subtitle: 'Batas shift: 07:00 - 12:00 WIB',
                      currentValue: 'Pilih Jam',
                      options: const <String>['07:30', '08:00', '08:30'],
                      disabledOptions: const <String>['08:00'],
                      optionSubtitles: const <String, String>{'08:00': 'dr. Budi'},
                      occupiedDetails: occupied,
                      isTimePicker: true,
                    ),
                  );
                },
                child: const Text('Buka Selection Sheet'),
              ),
            ),
          ),
        ),
      );

      // Open selection sheet
      await tester.tap(find.text('Buka Selection Sheet'));
      await tester.pumpAndSettle();

      // Tap disabled option '08:00'
      await tester.tap(find.text('08:00'));
      await tester.pumpAndSettle();

      // Verify that AmanahSlotOccupiedDetailDrawer is displayed with clean non-redundant content
      expect(find.byType(AmanahSlotOccupiedDetailDrawer), findsOneWidget);
      expect(find.text('Slot Telah Digunakan'), findsOneWidget);
      expect(find.text('dr. Budi Santoso, Sp.A'), findsOneWidget);
      expect(find.text('Poli Anak • Ruang 102'), findsOneWidget);
      expect(find.text('Slot waktu ini telah dialokasikan untuk jadwal praktik dokter lain.'), findsOneWidget);

      // Dismiss drawer via "Mengerti" button
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      // Drawer is closed
      expect(find.byType(AmanahSlotOccupiedDetailDrawer), findsNothing);
    });

    testWidgets('Tapping past slot triggers AmanahSlotOccupiedDetailDrawer with Waktu Sesi Selesai', (WidgetTester tester) async {
      final Map<String, SlotOccupiedInfo> occupied = <String, SlotOccupiedInfo>{
        '08:00': const SlotOccupiedInfo(
          time: '08:00',
          timeRange: 'Pukul 08:00 WIB',
          statusLabel: 'Sudah Selesai',
          occupiedBy: 'Waktu Telah Terlewati',
          reason: 'Slot waktu ini telah melewati jam operasional saat ini.',
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => ElevatedButton(
                onPressed: () {
                  AmanahSlotOccupiedDetailDrawer.show(
                    context,
                    time: '08:00',
                    info: occupied['08:00'],
                  );
                },
                child: const Text('Buka Detail'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Waktu Sesi Selesai'), findsOneWidget);
      expect(find.text('Shift Telah Terlewati'), findsOneWidget);
      expect(find.text('Slot waktu ini telah melewati jam operasional saat ini.'), findsOneWidget);
    });

    testWidgets('RescheduleStartTimePicker disables times and triggers occupied drawer on tap', (WidgetTester tester) async {
      String? selectedTime;
      final Map<String, SlotOccupiedInfo> occupied = <String, SlotOccupiedInfo>{
        '09:00': const SlotOccupiedInfo(
          time: '09:00',
          timeRange: '09:00 - 09:30 WIB',
          statusLabel: 'Jadwal Anda',
          occupiedBy: 'Jadwal Praktik Anda (Pagi)',
          poliName: 'Poli Umum',
          roomName: 'Ruang 101',
          reason: 'Anda telah memiliki sesi praktik Pagi pada tanggal target.',
        ),
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RescheduleStartTimePicker(
              selectedStartTime: selectedTime,
              disabledTimes: const <String>['09:00'],
              optionSubtitles: const <String, String>{'09:00': 'Jadwal Anda'},
              occupiedDetails: occupied,
              onTimeSelected: (String t) => selectedTime = t,
              dark: false,
            ),
          ),
        ),
      );

      // Tap selector to open bottom sheet
      await tester.tap(find.byType(RescheduleStartTimePicker));
      await tester.pumpAndSettle();

      expect(find.text('Pilih Jam Mulai Target'), findsOneWidget);

      // Tap disabled time 09:00
      await tester.tap(find.text('09:00'));
      await tester.pumpAndSettle();

      // Verify occupied drawer appears and time was NOT selected
      expect(find.byType(AmanahSlotOccupiedDetailDrawer), findsOneWidget);
      expect(find.text('Jadwal Praktik Anda'), findsWidgets);
      expect(selectedTime, isNull);

      // Close occupied drawer
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();
      expect(find.byType(AmanahSlotOccupiedDetailDrawer), findsNothing);

      // Tap an available time 08:30
      await tester.tap(find.text('08:30'));
      await tester.pumpAndSettle();

      // Available time should be selected
      expect(selectedTime, '08:30');
    });
  });
}
