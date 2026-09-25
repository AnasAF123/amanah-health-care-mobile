import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_row.dart';

class ScheduleSessionPanel extends StatelessWidget {
  const ScheduleSessionPanel({
    required this.session,
    this.occupancy,
    required this.dark,
    required this.onToggle,
    required this.onSlotChanged,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onOpenSelection,
    this.isPast = false,
    this.isUnavailable = false,
    this.unavailableReason,
    this.poliOptions = const <String>[],
    this.roomOptions = const <String>[],
    this.occupiedRoomOptions = const <String>[],
    this.selectedDate,
    this.allSessions = const <ScheduleFormSession>[],
    this.scheduleToEdit,
    super.key,
  });

  final ScheduleFormSession session;
  final ScheduleShiftOccupancy? occupancy;
  final bool dark;
  final bool isPast;
  final bool isUnavailable;
  final String? unavailableReason;
  final ValueChanged<bool> onToggle;
  final ScheduleSlotChanged onSlotChanged;
  final VoidCallback onAddSlot;
  final ValueChanged<int> onRemoveSlot;
  final OpenScheduleSelectionSheet onOpenSelection;
  final List<String> poliOptions;
  final List<String> roomOptions;
  final List<String> occupiedRoomOptions;
  final DateTime? selectedDate;
  final List<ScheduleFormSession> allSessions;
  final DoctorSchedule? scheduleToEdit;

  @override
  Widget build(BuildContext context) {
    final bool disabled = isPast || isUnavailable;
    final bool expanded = !disabled && session.active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: expanded
          ? const EdgeInsets.all(14)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: disabled
            ? (dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.02)
                : AmanahColorTokens.neutral100.withValues(alpha: 0.50))
            : dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
            : AmanahColorTokens.surfaceSecondaryLight,
        borderRadius: BorderRadius.circular(expanded ? 22 : 20),
        border: Border.all(
          color: expanded
              ? (dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                    : AmanahColorTokens.neutral200)
              : Colors.transparent,
        ),
        boxShadow: expanded && !dark
            ? <BoxShadow>[
                BoxShadow(
                  color: AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: disabled ? null : () => onToggle(!expanded),
            child: Padding(
              padding: EdgeInsets.only(bottom: expanded ? 12 : 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          session.name,
                          style: TextStyle(
                            color: disabled
                                ? (dark
                                    ? AmanahColorTokens.neutral500
                                    : AmanahColorTokens.neutral400)
                                : dark
                                ? AmanahColorTokens.pureWhite
                                : AmanahColorTokens.neutral900,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        () {
                          final SessionShiftBoundary bounds =
                              getSessionShiftBoundary(session.id);
                          final String rangeStr = occupancy?.timeRange ??
                              '${bounds.defaultStart} - ${bounds.defaultEnd} WIB';

                          if (isPast) {
                            return Text(
                              '$rangeStr • ${ScheduleFormConstants.badgeSudahSelesai}',
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.neutral500
                                    : AmanahColorTokens.neutral400,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }

                          if (isUnavailable) {
                            final String reason = unavailableReason ??
                                (occupancy != null && occupancy?.availableSlotsCount == 0
                                    ? ScheduleFormConstants.badgePenuh
                                    : ScheduleFormConstants.badgeWaktuHabis);
                            return Text(
                              '$rangeStr • $reason',
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.dangerDark
                                    : AmanahColorTokens.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }

                          final int availCount =
                              occupancy?.availableSlotsCount ?? 0;
                          final String availabilityStr = occupancy != null
                              ? (availCount > 0
                                  ? '$availCount ${ScheduleFormConstants.badgeTersedia}'
                                  : ScheduleFormConstants.badgePenuh)
                              : '';
                          final String fullSubtitle = availabilityStr.isNotEmpty
                              ? '$rangeStr • $availabilityStr'
                              : rangeStr;

                          return Text(
                            fullSubtitle,
                            style: TextStyle(
                              color: dark
                                  ? (expanded
                                        ? AmanahColorTokens.tabActiveDark
                                        : AmanahColorTokens.neutral400)
                                  : (expanded
                                        ? AmanahColorTokens.brand
                                        : AmanahColorTokens.neutral500),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }(),
                      ],
                    ),
                  ),
                  ScheduleToggleSwitch(
                    active: disabled ? false : expanded,
                    dark: dark,
                    disabled: disabled,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: expanded
                ? Column(
                    children: <Widget>[
                      for (int index = 0; index < session.slots.length; index++)
                        AnimatedSlotEntry(
                          key: ValueKey<String>(session.slots[index].id),
                          child: ScheduleSlotRow(
                            session: session,
                            slot: session.slots[index],
                            slotIndex: index,
                            occupancy: occupancy,
                            dark: dark,
                            showDivider: index > 0,
                            onOpenSelection: onOpenSelection,
                            onChanged: onSlotChanged,
                            onRemove: () => onRemoveSlot(index),
                            poliOptions: poliOptions,
                            roomOptions: roomOptions,
                            occupiedRoomOptions: occupiedRoomOptions,
                            selectedDate: selectedDate,
                            allSessions: allSessions,
                            scheduleToEdit: scheduleToEdit,
                          ),
                        ),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: onAddSlot,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: dark
                                ? AmanahColorTokens.pureWhite.withValues(
                                    alpha: 0.05,
                                  )
                                : AmanahColorTokens.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dark
                                  ? AmanahColorTokens.pureWhite.withValues(
                                      alpha: 0.10,
                                    )
                                  : AmanahColorTokens.neutral200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_rounded,
                                size: 16,
                                color: dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  color: dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
