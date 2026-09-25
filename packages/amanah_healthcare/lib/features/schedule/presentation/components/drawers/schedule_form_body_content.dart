import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_inline_calendar.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_session_builder.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_practice_status_switch.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_session_panel.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class ScheduleFormBodyContent extends StatelessWidget {
  const ScheduleFormBodyContent({
    required this.selectedDate,
    required this.calendarMonth,
    required this.isCalendarOpen,
    required this.status,
    this.statusOptions = const <String>[
      ScheduleFormConstants.statusBuka,
      ScheduleFormConstants.statusTutup,
    ],
    required this.sessions,
    required this.isEditing,
    required this.dark,
    required this.onStatusChanged,
    required this.onToggleCalendar,
    required this.onMonthChanged,
    required this.onSelectDate,
    required this.onToggleSession,
    required this.onSlotChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onOpenSelection,
    this.poliOptions = const <String>[],
    this.roomOptions = const <String>[],
    this.occupiedRoomOptions = const <String>[],
    this.scheduleToEdit,
    super.key,
  });

  final DateTime selectedDate;
  final DateTime calendarMonth;
  final bool isCalendarOpen;
  final String status;
  final List<String> statusOptions;
  final List<ScheduleFormSession> sessions;
  final bool isEditing;
  final bool dark;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onToggleCalendar;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onSelectDate;
  final void Function(String sessionId, [bool? forcedState]) onToggleSession;
  final void Function({
    required String sessionId,
    required int slotIndex,
    String? from,
    String? to,
    String? room,
    String? poli,
  }) onSlotChanged;
  final ValueChanged<String> onAddSlot;
  final void Function(String sessionId, int slotIndex) onRemoveSlot;
  final Future<void> Function({
    required String title,
    required String subtitle,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    List<String> disabledOptions,
    Map<String, String> optionSubtitles,
    Map<String, SlotOccupiedInfo> occupiedDetails,
    String? sessionId,
    bool isTimePicker,
  }) onOpenSelection;
  final List<String> poliOptions;
  final List<String> roomOptions;
  final List<String> occupiedRoomOptions;
  final DoctorSchedule? scheduleToEdit;

  @override
  Widget build(BuildContext context) {
    final bool isPracticeClosed =
        status == ScheduleFormConstants.statusTutup ||
        status == ScheduleFormConstants.statusCuti;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tanggal Praktik',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral200
                    : AmanahColorTokens.neutral700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isEditing)
              SchedulePracticeStatusSwitch(
                status: status,
                selectedDate: selectedDate,
                dark: dark,
                onChanged: onStatusChanged,
              ),
          ],
        ),
        const SizedBox(height: 6),
        ScheduleSelectorButton(
          value: formatIndonesianDate(selectedDate),
          icon: Icons.calendar_today_rounded,
          dark: dark,
          expanded: isCalendarOpen,
          onTap: onToggleCalendar,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: isCalendarOpen
              ? Padding(
                  key: const ValueKey<String>('inline-form-calendar'),
                  padding: const EdgeInsets.only(top: 8),
                  child: ScheduleFormInlineCalendar(
                    calendarMonth: calendarMonth,
                    selectedDate: selectedDate,
                    dark: dark,
                    onMonthChanged: onMonthChanged,
                    onSelectDate: onSelectDate,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        Text(
          'Sesi Praktik & Jam',
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral200
                : AmanahColorTokens.neutral700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isPracticeClosed) ...<Widget>[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.dangerDark.withValues(alpha: 0.15)
                  : AmanahColorTokens.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.dangerDark.withValues(alpha: 0.35)
                    : AmanahColorTokens.danger.withValues(alpha: 0.20),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.block_rounded,
                  size: 16,
                  color: AmanahColorTokens.danger,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Praktik Ditutup. Sesi dan antrean pada tanggal ini dinonaktifkan.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        IgnorePointer(
          ignoring: isPracticeClosed,
          child: Opacity(
            opacity: isPracticeClosed ? 0.45 : 1.0,
            child: Column(
              children: <Widget>[
                for (final ScheduleFormSession session in sessions) ...<Widget>[
                  () {
                    final String targetShift = sessionShiftFromId(session.id);
                    final ScheduleContext? storeCtx = AmanahScheduleStore
                        .instance.scheduleContexts
                        .where((ScheduleContext c) =>
                            c.sessionShift == targetShift ||
                            c.sessionShift == session.id ||
                            c.contextId == session.id ||
                            c.contextId == targetShift)
                        .firstOrNull;

                    final ScheduleShiftOccupancy? shiftOcc = AmanahScheduleStore
                        .instance.occupancyOverview?.shifts
                        .where((ScheduleShiftOccupancy s) =>
                            s.shift == targetShift ||
                            s.shift == session.id ||
                            s.shift.toLowerCase() == targetShift.toLowerCase() ||
                            s.shift.toLowerCase() == session.id.toLowerCase())
                        .firstOrNull;

                    final bool isPast = isSessionShiftPast(
                      sessionId: session.id,
                      selectedDate: selectedDate,
                      context: storeCtx,
                    );

                    final bool isEditingThisSession = scheduleToEdit != null &&
                        (session.slots.any((ScheduleFormSlot sl) => sl.id == scheduleToEdit!.id) ||
                         session.id == sessionIdFromType(scheduleToEdit!.sessionType));

                    final bool isUnavailable = isSessionShiftUnavailable(
                      sessionId: session.id,
                      selectedDate: selectedDate,
                      occupancy: shiftOcc,
                      context: storeCtx,
                      isEditingThisSession: isEditingThisSession,
                    );

                    return ScheduleSessionPanel(
                      session: session,
                      occupancy: shiftOcc,
                      isPast: isPast,
                      isUnavailable: isUnavailable,
                      dark: dark,
                      onToggle: (bool value) => onToggleSession(session.id, value),
                      onSlotChanged: ({
                        required int slotIndex,
                        String? from,
                        String? to,
                        String? room,
                        String? poli,
                      }) {
                        onSlotChanged(
                          sessionId: session.id,
                          slotIndex: slotIndex,
                          from: from,
                          to: to,
                          room: room,
                          poli: poli,
                        );
                      },
                      onAddSlot: () => onAddSlot(session.id),
                      onRemoveSlot: (int slotIndex) =>
                          onRemoveSlot(session.id, slotIndex),
                      onOpenSelection: onOpenSelection,
                      poliOptions: poliOptions,
                      roomOptions: roomOptions,
                      occupiedRoomOptions: occupiedRoomOptions,
                      selectedDate: selectedDate,
                      allSessions: sessions,
                      scheduleToEdit: scheduleToEdit,
                    );
                  }(),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AmanahSpacing.xxl),
      ],
    );
  }
}
