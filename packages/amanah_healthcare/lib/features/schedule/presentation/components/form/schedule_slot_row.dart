import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_collision_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_row_components.dart';

export 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_row_components.dart';

const List<String> kRoomOptions = <String>[];
const List<String> kPoliOptions = <String>[];

typedef OpenScheduleSelectionSheet =
    Future<void> Function({
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
    });

typedef ScheduleSlotChanged =
    void Function({
      required int slotIndex,
      String? from,
      String? to,
      String? room,
      String? poli,
    });

class ScheduleSlotRow extends StatelessWidget {
  const ScheduleSlotRow({
    required this.session,
    required this.slot,
    required this.slotIndex,
    this.occupancy,
    required this.dark,
    required this.showDivider,
    required this.onOpenSelection,
    required this.onChanged,
    required this.onRemove,
    this.poliOptions = const <String>[],
    this.roomOptions = const <String>[],
    this.occupiedRoomOptions = const <String>[],
    this.selectedDate,
    this.allSessions = const <ScheduleFormSession>[],
    this.scheduleToEdit,
    super.key,
  });

  final ScheduleFormSession session;
  final ScheduleFormSlot slot;
  final int slotIndex;
  final ScheduleShiftOccupancy? occupancy;
  final bool dark;
  final bool showDivider;
  final OpenScheduleSelectionSheet onOpenSelection;
  final ScheduleSlotChanged onChanged;
  final VoidCallback onRemove;
  final List<String> poliOptions;
  final List<String> roomOptions;
  final List<String> occupiedRoomOptions;
  final DateTime? selectedDate;
  final List<ScheduleFormSession> allSessions;
  final DoctorSchedule? scheduleToEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (showDivider)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                      : AmanahColorTokens.neutral300,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        Row(
          children: <Widget>[
            SlotLabel(text: 'From', dark: dark),
            Expanded(
              child: MiniSlotButton(
                value: slot.from,
                dark: dark,
                onTap: () async {
                  final AmanahScheduleStore store = AmanahScheduleStore.instance;
                  final String? targetRoomId = (slot.room.isNotEmpty &&
                          slot.room != ScheduleFormConstants.selectRoom)
                      ? store.rooms
                          .where((ClinicRoomReference r) => r.name == slot.room)
                          .firstOrNull
                          ?.id
                      : store.formBootstrap?.doctor.defaultRoomId;

                  final SessionShiftBoundary bounds =
                      getSessionShiftBoundary(session.id);

                  if (selectedDate != null &&
                      targetRoomId != null &&
                      targetRoomId.isNotEmpty) {
                    final ScheduleSlotAvailabilityData? availability =
                        await store.loadSlotAvailability(
                      date: selectedDate!,
                      shift: session.id,
                      roomId: targetRoomId,
                      scheduleId: scheduleToEdit?.id,
                    );

                    if (availability != null && availability.slots.isNotEmpty) {
                      final List<String> timeOptions = availability.slots
                          .map((ScheduleSlotAvailabilityItem s) => s.time)
                          .toList();
                      final List<String> disabledTimes = availability.slots
                          .where((ScheduleSlotAvailabilityItem s) => !s.isAvailable)
                          .map((ScheduleSlotAvailabilityItem s) => s.time)
                          .toList();
                      final Map<String, String> subtitles = <String, String>{
                        for (final ScheduleSlotAvailabilityItem s in availability.slots)
                          s.time: s.displayLabel,
                      };
                      final Map<String, SlotOccupiedInfo> occupiedDetails =
                          <String, SlotOccupiedInfo>{
                        for (final ScheduleSlotAvailabilityItem s in availability.slots)
                          if (!s.isAvailable)
                            s.time: SlotOccupiedInfo(
                              time: s.time,
                              timeRange: '${s.time} - ${s.endTime} WIB',
                              statusLabel: s.displayLabel,
                              occupiedBy: s.conflict?.occupantName ?? s.displayLabel,
                              roomName: availability.roomName,
                              reason: s.conflict?.reason ??
                                  'Slot tidak tersedia pada jam ini.',
                            ),
                      };

                      for (final ScheduleFormSlot otherSlot in session.slots) {
                        if (otherSlot.id != slot.id &&
                            otherSlot.from.isNotEmpty &&
                            otherSlot.from != ScheduleFormConstants.selectTime) {
                          if (!disabledTimes.contains(otherSlot.from)) {
                            disabledTimes.add(otherSlot.from);
                          }
                          subtitles[otherSlot.from] = 'Antrean lain';
                        }
                      }

                      onOpenSelection(
                        title: 'Pilih Waktu Mulai (${session.name})',
                        subtitle:
                            'Batas shift: ${bounds.defaultStart} - ${bounds.defaultEnd} WIB',
                        currentValue: slot.from,
                        options: timeOptions,
                        disabledOptions: disabledTimes,
                        optionSubtitles: subtitles,
                        occupiedDetails: occupiedDetails,
                        sessionId: session.id,
                        isTimePicker: true,
                        onChanged: (String value) =>
                            onChanged(slotIndex: slotIndex, from: value),
                      );
                      return;
                    }
                  }

                  if (store.occupancyOverview == null && selectedDate != null) {
                    await store.loadOccupancyOverview(
                      date: selectedDate!,
                      roomId: targetRoomId,
                    );
                  }

                  final String targetShift = sessionShiftFromId(session.id);
                  final ScheduleShiftOccupancy? effectiveOccupancy =
                      store.occupancyOverview?.shifts
                          .where((ScheduleShiftOccupancy s) =>
                              s.shift == targetShift ||
                              s.shift == session.id ||
                              s.shift.toLowerCase() == targetShift.toLowerCase() ||
                              s.shift.toLowerCase() == session.id.toLowerCase())
                          .firstOrNull ??
                      occupancy;

                  final ScheduleContext? ctx = store.scheduleContexts
                      .where((ScheduleContext c) =>
                          c.sessionShift == targetShift ||
                          c.sessionShift == session.id ||
                          c.contextId == session.id ||
                          c.contextId == targetShift)
                      .firstOrNull;

                  final List<DoctorSchedule> existingSchedules =
                      selectedDate != null
                          ? store.getSchedulesForDate(selectedDate!)
                          : const <DoctorSchedule>[];

                  final collision =
                      ScheduleSlotCollisionHelper.computeSlotTimeOptions(
                    sessionId: session.id,
                    currentSlot: slot,
                    sessionSlots: session.slots,
                    allSessions: allSessions,
                    occupancy: effectiveOccupancy,
                    context: ctx,
                    selectedDate: selectedDate,
                    existingSchedules: existingSchedules,
                    editingScheduleId: scheduleToEdit?.id,
                  );

                  onOpenSelection(
                    title: 'Pilih Waktu Mulai (${session.name})',
                    subtitle:
                        'Batas shift: ${formatMinutesToTime(bounds.startMinutes)} - ${formatMinutesToTime(bounds.endMinutes)} WIB',
                    currentValue: slot.from,
                    options: collision.timeOptions,
                    disabledOptions: collision.disabledTimes,
                    optionSubtitles: collision.subtitles,
                    occupiedDetails: collision.occupiedDetails,
                    sessionId: session.id,
                    isTimePicker: true,
                    onChanged: (String value) =>
                        onChanged(slotIndex: slotIndex, from: value),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            SlotLabel(
              text: 'To',
              dark: dark,
            ),
            Expanded(
              child: MiniSlotButton(
                value: slot.to,
                dark: dark,
                onTap: null,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onRemove,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AmanahColorTokens.neutral400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: <Widget>[
            Expanded(
              child: SlotFieldColumn(
                label: 'Ruang Praktik',
                value: slot.room.isNotEmpty
                    ? slot.room
                    : ScheduleFormConstants.selectRoom,
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Ruang Praktik',
                  subtitle: 'Pilih ruangan praktik dokter',
                  currentValue: slot.room.isNotEmpty
                      ? slot.room
                      : ScheduleFormConstants.selectRoom,
                  options: roomOptions,
                  disabledOptions: occupiedRoomOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, room: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SlotFieldColumn(
                label: 'Poli / Spesialisasi',
                value: slot.poli.isNotEmpty
                    ? slot.poli
                    : ScheduleFormConstants.selectPoli,
                dark: dark,
                onTap: () => onOpenSelection(
                  title: 'Pilih Poli / Spesialisasi',
                  subtitle: 'Pilih poliklinik atau bidang spesialisasi',
                  currentValue: slot.poli.isNotEmpty
                      ? slot.poli
                      : ScheduleFormConstants.selectPoli,
                  options: poliOptions,
                  onChanged: (String value) =>
                      onChanged(slotIndex: slotIndex, poli: value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
