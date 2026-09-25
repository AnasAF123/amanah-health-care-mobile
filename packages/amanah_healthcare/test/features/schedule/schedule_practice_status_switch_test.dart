import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/amanah_confirm_close_practice_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_body_content.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_practice_status_switch.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';

void main() {
  group('SchedulePracticeStatusSwitch Widget Tests', () {
    testWidgets('Renders "Buka" and tapping triggers confirmation drawer',
        (WidgetTester tester) async {
      String? changedTo;
      final DateTime testDate = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SchedulePracticeStatusSwitch(
                status: 'Buka',
                selectedDate: testDate,
                dark: false,
                onChanged: (String val) => changedTo = val,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Buka'), findsOneWidget);
      expect(find.text('Tutup'), findsNothing);

      // Tap the switch
      await tester.tap(find.byType(SchedulePracticeStatusSwitch));
      await tester.pumpAndSettle();

      // Confirmation drawer appears
      expect(find.byType(AmanahConfirmClosePracticeDrawer), findsOneWidget);
      expect(find.text('Tutup Jadwal Praktik'), findsOneWidget);
      expect(find.text('Ya, Tutup'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahConfirmClosePracticeDrawer), findsNothing);
      expect(changedTo, isNull);

      // Tap again and confirm
      await tester.tap(find.byType(SchedulePracticeStatusSwitch));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ya, Tutup'));
      await tester.pumpAndSettle();

      expect(find.byType(AmanahConfirmClosePracticeDrawer), findsNothing);
      expect(changedTo, 'Tutup');
    });

    testWidgets('Renders "Tutup" and tapping immediately re-opens without drawer',
        (WidgetTester tester) async {
      String? changedTo;
      final DateTime testDate = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SchedulePracticeStatusSwitch(
                status: 'Tutup',
                selectedDate: testDate,
                dark: false,
                onChanged: (String val) => changedTo = val,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tutup'), findsOneWidget);
      expect(find.text('Buka'), findsNothing);

      // Tap the switch
      await tester.tap(find.byType(SchedulePracticeStatusSwitch));
      await tester.pumpAndSettle();

      // Confirmation drawer is NOT shown
      expect(find.byType(AmanahConfirmClosePracticeDrawer), findsNothing);
      expect(changedTo, 'Buka');
    });
  });

  group('ScheduleFormBodyContent Status Switch & Closed Banner Tests', () {
    testWidgets('Shows switch only on edit mode and disables sessions when closed',
        (WidgetTester tester) async {
      final DateTime testDate = DateTime(2026, 9, 25);
      final List<ScheduleFormSession> dummySessions = <ScheduleFormSession>[
        const ScheduleFormSession(
          id: 'pagi',
          name: 'Sesi Pagi',
          sessionType: 'Pagi',
          active: true,
          slots: <ScheduleFormSlot>[
            ScheduleFormSlot(
              id: 'slot-1',
              from: '08:00',
              to: '12:00',
              room: 'Ruang 101',
              poli: 'Poli Umum',
            ),
          ],
        ),
      ];

      // 1. Add mode (isEditing: false) -> switch should NOT be present
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleFormBodyContent(
                selectedDate: testDate,
                calendarMonth: testDate,
                isCalendarOpen: false,
                status: 'Buka',
                sessions: dummySessions,
                isEditing: false,
                dark: false,
                onStatusChanged: (_) {},
                onToggleCalendar: () {},
                onMonthChanged: (_) {},
                onSelectDate: (_) {},
                onToggleSession: (String _, [bool? active]) {},
                onSlotChanged: ({
                  required String sessionId,
                  required int slotIndex,
                  String? from,
                  String? to,
                  String? room,
                  String? poli,
                }) {},
                onAddSlot: (_) {},
                onRemoveSlot: (String _, int index) {},
                onOpenSelection: ({
                  required String title,
                  required String subtitle,
                  required String currentValue,
                  required List<String> options,
                  required ValueChanged<String> onChanged,
                  List<String> disabledOptions = const <String>[],
                  Map<String, String> optionSubtitles = const <String, String>{},
                  Map<String, dynamic> occupiedDetails = const <String, dynamic>{},
                  String? sessionId,
                  bool isTimePicker = false,
                }) async {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tanggal Praktik'), findsOneWidget);
      expect(find.byType(SchedulePracticeStatusSwitch), findsNothing);

      // 2. Edit mode (isEditing: true) with status 'Tutup' -> shows switch and closed notice
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleFormBodyContent(
                selectedDate: testDate,
                calendarMonth: testDate,
                isCalendarOpen: false,
                status: 'Tutup',
                sessions: dummySessions,
                isEditing: true,
                dark: false,
                scheduleToEdit: DoctorSchedule(
                  id: 'sch-1',
                  title: 'Sesi Pagi',
                  date: '25 Sep 2026',
                  time: '08:00 - 12:00 WIB',
                  startTime: '08:00',
                  endTime: '12:00',
                  sessionType: 'Pagi',
                  sessionShift: 'pagi',
                  poli: 'Poli Umum',
                  room: 'Ruang 101',
                  slotCount: '0',
                  slotText: '0 Pasien',
                  isAvailable: false,
                  badge: 'Tutup',
                  badgeVariant: AmanahBadgeVariant.warning,
                ),
                onStatusChanged: (_) {},
                onToggleCalendar: () {},
                onMonthChanged: (_) {},
                onSelectDate: (_) {},
                onToggleSession: (String _, [bool? active]) {},
                onSlotChanged: ({
                  required String sessionId,
                  required int slotIndex,
                  String? from,
                  String? to,
                  String? room,
                  String? poli,
                }) {},
                onAddSlot: (_) {},
                onRemoveSlot: (String _, int index) {},
                onOpenSelection: ({
                  required String title,
                  required String subtitle,
                  required String currentValue,
                  required List<String> options,
                  required ValueChanged<String> onChanged,
                  List<String> disabledOptions = const <String>[],
                  Map<String, String> optionSubtitles = const <String, String>{},
                  Map<String, dynamic> occupiedDetails = const <String, dynamic>{},
                  String? sessionId,
                  bool isTimePicker = false,
                }) async {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SchedulePracticeStatusSwitch), findsOneWidget);
      expect(find.text('Tutup'), findsWidgets);
      expect(
        find.text('Praktik Ditutup. Sesi dan antrean pada tanggal ini dinonaktifkan.'),
        findsOneWidget,
      );

      // Verify sessions are wrapped in IgnorePointer with ignoring: true
      final Finder ignoreFinder = find.ancestor(
        of: find.text('Sesi Pagi'),
        matching: find.byType(IgnorePointer),
      );
      expect(ignoreFinder, findsWidgets);
      final IgnorePointer ignoreWidget = tester.widget<IgnorePointer>(ignoreFinder.first);
      expect(ignoreWidget.ignoring, isTrue);
    });
  });
}
